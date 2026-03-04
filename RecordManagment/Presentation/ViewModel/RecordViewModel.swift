
import SwiftUI
import Combine

@MainActor
class RecordViewModel: ObservableObject {

    @Published var detailRecords: [IntergrationRecord] = []
    @Published var filterdRecords: [IntergrationRecord] = []
    @Published var currentRecords: [IntergrationRecord] = []
    @Published var selectedDate: Date? = .now
    @Published var currentRecordCount: Int = 0
    @Published var record: DropDownFilter = .all
    
    private var cancellables = Set<AnyCancellable>()
    let refreshSubject = PassthroughSubject<Void, Never>() // records update를 위한 Publisher
    let useCase: RecordUseCase
    let settingUseCase: SettingUseCase
    init(useCase: RecordUseCase, settingUseCase: SettingUseCase) {
        self.useCase = useCase
        self.settingUseCase = settingUseCase
        let dateChangePublisher = $selectedDate
            .compactMap { $0 }
            .removeDuplicates()

        let refreshPublisher = refreshSubject
            .compactMap { [weak self] in
                return self?.selectedDate
            }

        Publishers.Merge(dateChangePublisher, refreshPublisher)
            .prepend(selectedDate ?? .now)
            .sink { [weak self] date in
                Task {
                    try await self?.fetch(for: date)
                }
            }
            .store(in: &cancellables)
    }

    func fetch(for date: Date) async throws {
        do {
            self.detailRecords = try await useCase.fetchRecords(date)
            self.filterdRecords = self.detailRecords.filter{ $0.name == record.name}
        } catch {
            debugPrint("detailRecord fetch 실패 : \(error)")
        }
    }
    
    func currentDayFetch(for date: Date) async throws {
        do {
            self.currentRecords = try await useCase.fetchRecords(.now)
            self.currentRecordCount = currentRecords.count
        } catch {
            debugPrint("current Reocrds Count 실패 : \(error)")
        }
    }
}


// MARK: Daily, Exercise for SheetView on Delete
extension RecordViewModel {
    func deleteDaily(id recordId: String) async -> Bool {
        let result = await useCase.dailyDelete(recordId)
        
        switch result {
            case .success(_):
                return true
            case .failure(let err):
                debugPrint(err)
                return false
        }
    }
    
    func deleteExercise(id recordId: String) async -> Bool {
        let result = await useCase.exerciseDelete(recordId)
        
        switch result {
            case .success(_):
                return true
            case .failure(let err):
                debugPrint(err)
                return false
        }
    }
    
    func deleteHabit(id recordId: String) async -> Bool {
        let result = await useCase.habitDelete(recordId)
        
        switch result {
            case .success(_):
                return true
            case .failure(let err):
                debugPrint(err)
                return false
        }
    }
}


// MARK: Habit Case
extension RecordViewModel {
    // TODO: 현재 습관기록이 서브로 -> 습관 기록( 메인 )으로 변경 가능한 경우
    func changeMainRecordPossible() -> Bool {
        guard !currentRecords.isEmpty else { return false}
        return currentRecords.contains(where: {
            if case .habit(let habit) = $0 {
                return habit.isMainRecord
            } else {
                return false
            }
        })
    }
}


// MARK: 목표 초기화 함수
extension RecordViewModel {
    func resetGoal() async throws {
        do {
            try await settingUseCase.reset()
        } catch {
            debugPrint("목표 초기화 : \(error)")
        }
    }
}
