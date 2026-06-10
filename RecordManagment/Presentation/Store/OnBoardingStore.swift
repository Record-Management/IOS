import SwiftUI
import Combine

/// 온보딩 화면을 책임질 Store
@MainActor
@Observable
final class OnBoardingStore {
    struct State {
        var currentProgress: ProgressPage = .record
        var currentPage: GoalReSelection.CurrentPage = .record // 재설정 Progress Page
        var currentRecord: SeedType = .none
        var name: String = ""
        var isValidName: Bool = false
        var selectGoal: SectionFourView.GoalTypes = .none
        var isGrant: Bool? = nil
        var selectedDate: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now
        var isGrantAlert: Bool = false
        var firstOnBoarding: Bool
        var birthPartSkip: Bool = false
        var isReSelection: Bool = false
    }
    // store
    let authStore: AuthStore
    
    // 상태
    private(set) var state: State
    
    // 의존성
    private let useCase: SectionOnBoardingUseCase
    private let noticeService: NotificationService = .shared
    
    init(
        useCase: SectionOnBoardingUseCase,
        authStore: AuthStore,
        firstOnBoarding: Bool = true
    ) {
        self.useCase = useCase
        self.authStore = authStore
        self.state = State(firstOnBoarding: firstOnBoarding)
    }
    
    enum Intent {
        // Binding
        case bindingCurrentProgress(ProgressPage)
        case bindingCurrentPage(GoalReSelection.CurrentPage)
        case bindingCurrentRecord(SeedType)
        case bindingName(String)
        case bindingSelectGoal(SectionFourView.GoalTypes)
        case bindingIsGrant(Bool?)
        case bindingSelectedDate(Date)
        case bindingIsGrantAlert(Bool)
        case bindingBirthPartSkip(Bool)
        case bindingIsReSelection(Bool)
        case updateFirstOnBoarding(Bool)
        // Notification
        case requestPermission
        case checkPermission
        // Network
        case onBoardingComplete
        case onBoardingReSelection
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .updateFirstOnBoarding(let first):
            state.firstOnBoarding = first
        case .bindingCurrentProgress(let progress):
            state.currentProgress = progress
        case .bindingCurrentPage(let page):
            state.currentPage = page
        case .bindingCurrentRecord(let seedType):
            state.currentRecord = seedType
        case .bindingName(let newName):
            state.name = newName
            let isValid = validateName(newName)
            if state.isValidName != isValid {
                withAnimation(.smooth) {
                    state.isValidName = isValid
                }
            }
        case .bindingSelectGoal(let goal):
            state.selectGoal = goal
        case .bindingIsGrant(let isGrant):
            state.isGrant = isGrant
        case .bindingSelectedDate(let date):
            state.selectedDate = date
        case .bindingIsGrantAlert(let showAlert):
            state.isGrantAlert = showAlert
        case .bindingBirthPartSkip(let skip):
            state.birthPartSkip = skip
        case .bindingIsReSelection(let reSelect):
            state.isReSelection = reSelect
            
        case .requestPermission:
            Task {
                let grant = await noticeService.requestNotificationPermission()
                if !grant {
                    state.isGrantAlert = true
                } else {
                    state.isGrant = grant
                }
            }
        case .checkPermission:
            Task {
                let status = await noticeService.getNotificationAuthorizationStatus()
                switch status {
                case .authorized, .provisional, .ephemeral:
                    state.isGrant = true
                default:
                    state.isGrant = false
                }
            }
            
        case .onBoardingComplete:
            Task { await completeOnBoarding() }
        case .onBoardingReSelection:
            Task { await onBoardingReSelection() }
        }
    }
    
    // MARK: - 이름 유효성 검사
    
    private func validateName(_ name: String) -> Bool {
        if name.isEmpty { return false }
        guard name.count <= 6 else { return false }
        return name.range(of: "^[a-zA-Z0-9가-힣]+$", options: .regularExpression) != nil
    }
    
    // MARK: - 온보딩 완료
    
    func completeOnBoarding() async {
        do {
            guard let onBoarding = makeOnBoardingDTO() else { return }
            let isCompleted = try await useCase.onBoardingFetchingComplete(dto: onBoarding)
            authStore.send(.updateState(isCompleted ? .main : .register))
        } catch {
            Log.error("온보딩 완료 실패 : \(error.localizedDescription)")
            authStore.send(.updateState(.login))
        }
    }
    
    // MARK: - 목표 재설정 함수
    
    func onBoardingReSelection() async {
        do {
            let form = makeReSelectionGoal()
            let result: GoalResponse = try await useCase.reSelectionOnBoarding(dto: form)
            Log.info("목표 재설정 : \(result)")
            AnalyticsManager.shared.logGoalResetComplete(form.recordType, goalDays: form.goalDays)
            authStore.send(.updateState(.main))
        } catch {
            Log.error("온보딩 재설정 실패 : \(error.localizedDescription)")
            authStore.send(.updateState(.login))
        }
    }
    
    // MARK: - OnBoarding Object
    
    private func makeReSelectionGoal() -> GoalReSelectionRequestBody {
        GoalReSelectionRequestBody(
            recordType: state.currentRecord.localizedString(),
            goalDays: state.selectGoal.localizedInt()
        )
    }
    
    private func makeOnBoardingDTO() -> OnBoardingDTO? {
        return OnBoardingDTO(
            nickName: state.name,
            mainRecordType: state.currentRecord.localizedString(),
            birthDate: state.birthPartSkip ? nil : Date.onBoardingFormet(state.selectedDate),
            goalDays: state.selectGoal.localizedInt()
        )
    }
}

extension OnBoardingStore: Hashable {
    nonisolated public static func == (lhs: OnBoardingStore, rhs: OnBoardingStore) -> Bool {
        lhs === rhs
    }
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
