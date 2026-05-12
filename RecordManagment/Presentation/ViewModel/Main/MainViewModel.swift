import SwiftUI
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    
    // MARK: - Published Properties (Combined Record & Selection)
    
    // From Record (Records & Date)
    @Published var detailRecords: [IntergrationRecord] = []
    @Published var filterdRecords: [IntergrationRecord] = []
    @Published var currentRecords: [IntergrationRecord] = []
    @Published var selectedDate: Date? = .now
    @Published var currentRecordCount: Int = 0
    @Published var recordFilter: DropDownFilter = .all
    
    // From Selection (User & Stage)
    @Published var isAlert: Bool = false
    @Published var originalRecord: SeedType = .none
    @Published var currentRecord: SeedType = .daily
    @Published var selectedRecord: SeedType = .none
    @Published var user: User = .init(statusCode: 0, code: "", message: "", data: nil)
    @Published var stage: String?
    
    // UI States
    @Published var offset: CGFloat = 0
    @Published var topDetent: CGFloat = 0
    @Published var navBarHeight: CGFloat = 0
    @Published var isShow: Bool = false
    @Published var isGoalReset: Bool = false
    @Published var isAppReviewShow: Bool = false
    @Published var isFloatingExtends: Bool = false
    
    // MARK: - Dependencies
    
    private let userRepository: UserRepository
    private let recordUseCase: RecordUseCase
    private let settingUseCase: SettingUseCase
    
    private var cancellables = Set<AnyCancellable>()
    let refreshSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Initializer
    
    init(
        userRepository: UserRepository,
        recordUseCase: RecordUseCase,
        settingUseCase: SettingUseCase
    ) {
        self.userRepository = userRepository
        self.recordUseCase = recordUseCase
        self.settingUseCase = settingUseCase
        
        setupSubscribers()
    }
    
    // MARK: - Setup
    
    private func setupSubscribers() {
        // Record Fetch Subscriber
        let dateChangePublisher = $selectedDate
            .compactMap { $0 }
            .removeDuplicates { Calendar.current.isDate($0, inSameDayAs: $1) }

        let refreshPublisher = refreshSubject
            .compactMap { [weak self] in
                return self?.selectedDate
            }

        Publishers.Merge(dateChangePublisher, refreshPublisher)
            .sink { [weak self] date in
                Task {
                    try await self?.fetchRecords(for: date)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Record Logic
extension MainViewModel {
    func fetchRecords(for date: Date) async throws {
        do {
            let records = try await recordUseCase.fetchRecords(date)
            self.detailRecords = records
            self.filterdRecords = records.filter { $0.name == recordFilter.name }
            
            if Calendar.current.isDateInToday(date) {
                self.currentRecords = records
                self.currentRecordCount = records.count
            }
        } catch {
            debugPrint("detailRecord fetch 실패 : \(error)")
        }
    }
    
    func deleteDaily(id recordId: String) async -> Bool {
        let result = await recordUseCase.dailyDelete(recordId)
        switch result {
            case .success(_): return true
            case .failure(let err):
                debugPrint(err)
                return false
        }
    }
    
    func deleteExercise(id recordId: String) async -> Bool {
        let result = await recordUseCase.exerciseDelete(recordId)
        switch result {
            case .success(_): return true
            case .failure(let err):
                debugPrint(err)
                return false
        }
    }
    
    func deleteHabit(id recordId: String) async -> Bool {
        let result = await recordUseCase.habitDelete(recordId)
        switch result {
            case .success(_): return true
            case .failure(let err):
                debugPrint(err)
                return false
        }
    }
    
    func currentDayFetch(for date: Date) async throws {
        try await fetchRecords(for: .now)
    }
    
    func changeMainRecordPossible() -> Bool {
        guard !currentRecords.isEmpty else { return false }
        return currentRecords.contains(where: {
            if case .habit(let habit) = $0 {
                return habit.isMainRecord
            } else {
                return false
            }
        })
    }
    
    func resetGoal() async throws {
        do {
            try await settingUseCase.reset()
        } catch {
            debugPrint("목표 초기화 : \(error)")
        }
    }
}

// MARK: - User & Selection Logic
extension MainViewModel {
    func getCurrentRecordType() async -> SeedType {
        do {
            let result = try await userRepository.fetchMyInfo()
            switch result {
                case .success(let res):
                    if let data = res.data {
                        self.user.data = data
                        self.stage = data.currentTreeStage
                        let type = SeedType.matchingMainRecordType(data.mainRecordType ?? "")
                        self.currentRecord = type
                        self.originalRecord = type
                        return type
                    }
                case .failure(let err):
                    debugPrint("User Error : \(err)")
            }
        } catch {
            debugPrint("getCurrentRecordType catch Error : \(error)")
        }
        return .none
    }
    
    func getStage() -> String {
        switch stage {
            case "STAGE_1": "MainStep01"
            case "STAGE_2": "MainStep02"
            case "STAGE_3": "MainStep03"
            case "STAGE_4": "MainStep04"
            default: "MainStepNone"
        }
    }
    
    func matchingStage(isTutorial: Bool) -> SeedStep {
        switch stage {
            case "STAGE_1": return .stage1
            case "STAGE_2": return .stage2
            case "STAGE_3": return .stage2
            case "STAGE_4": return .stage3
            default:
                guard isTutorial else { return .tutorial }
                return .none
        }
    }
}
