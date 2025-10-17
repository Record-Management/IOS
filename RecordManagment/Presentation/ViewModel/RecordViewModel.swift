
import SwiftUI
import Combine

@MainActor
class RecordViewModel: ObservableObject {

    @Published var detailRecords: [IntergrationRecord] = []
    @Published var selectedDate: Date? = .now
    
    private var cancellables = Set<AnyCancellable>()
    let refreshSubject = PassthroughSubject<Void, Never>() // records update를 위한 Publisher
    let useCase: RecordUseCase
    init(useCase: RecordUseCase) {
        self.useCase = useCase
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
        } catch {
            debugPrint("detailRecord fetch 실패 : \(error)")
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
