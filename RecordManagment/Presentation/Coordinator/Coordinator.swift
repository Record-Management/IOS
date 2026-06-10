import SwiftUI

// MARK: - Hashable Conformances for ViewModels

extension SettingView.ViewModel: Hashable {
    nonisolated public static func == (lhs: SettingView.ViewModel, rhs: SettingView.ViewModel) -> Bool {
        lhs === rhs
    }
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

// MARK: - Navigation Enums

enum Page: Identifiable, Hashable, Equatable, Sendable {
    case root
    case admin
    case login
    case term
    case section
    case finalOnBoarding(message: String?)
    case main
    case dailyRecordEdit(vm: DayRecordView.ViewModel)
    case exerciseRecordEdit(vm: ExerciseRecordView.ViewModel)
    case habitRecordEdit(vm: HabitRecordView.ViewModel)
    case scheduleRecordEdit(vm: ScheduleViewModel)
    case setting
    case appNotice
    case recordNotice
    case notification
    case goalSelection
    
    var id: Int { self.hashValue }
}

enum Sheet: Identifiable, Hashable {
    case nickName
    
    var id: Int { self.hashValue }
}

enum FullScreenCover: Identifiable, Hashable {
    case recordSelection
    case dailyRecord(vm: DayRecordView.ViewModel)
    case exerciseRecord(vm: ExerciseRecordView.ViewModel)
    case habitRecord(vm: HabitRecordView.ViewModel)
    case scheduleRecord(vm: ScheduleViewModel)
    case achievementGoal(goal: RecentHistoryData, achiveCount: Int)
    
    var id: Int { self.hashValue }
}

// MARK: - Coordinator

@MainActor
final class Coordinator: ObservableObject {
    @Published var path: [Page] = []
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    @Published private(set) var isFloatingButtonVisible: Bool = false
    @Published private(set) var isNoGoalPeriodVisible: Bool = false
    
    let appContainer: AppContainer
    private let routerStore: RouterStore
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.routerStore = appContainer.makeRouterStore()
    }
    
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
            case .root: RouterView(store: routerStore)
            case .admin: AdministrationView()
            case .login: appContainer.makeSocialView()
            case .term: TermsOfUseView()
            case .section: appContainer.makeSectionView()
            case .finalOnBoarding(let message): appContainer.makeFinalOnBoardingView(toastMessage: message)
            case .main: appContainer.makeMainView()
            case .notification: appContainer.makeNotificationView()
            case .setting: appContainer.makeSettingView()
            case .dailyRecordEdit(let vm): appContainer.makeDayRecordEditView(vm: vm)
            case .exerciseRecordEdit(let vm): appContainer.makeExerciseRecordEditView(vm: vm)
            case .habitRecordEdit(let vm): appContainer.makeHabitRecordEditView(vm: vm)
            case .scheduleRecordEdit(let vm): appContainer.makeScheduleRecordEditView(vm: vm)
            case .appNotice: appContainer.makeAppNoticeView()
            case .recordNotice: appContainer.makeRecordNoticeView()
            case .goalSelection: appContainer.makeGoalReSelectionView()
        }
    }
    
    @ViewBuilder
    func build(sheet: Sheet) -> some View {
        switch sheet {
            case .nickName: appContainer.makeNickNameChangeView()
        }
    }
    
    @ViewBuilder
    func build(fullScreenCover: FullScreenCover) -> some View {
        switch fullScreenCover {
            case .recordSelection: appContainer.makeRecordSelectionView()
            case .dailyRecord(let vm): appContainer.makeDayRecordView(vm: vm)
            case .exerciseRecord(let vm): appContainer.makeExerciseRecordView(vm: vm)
            case .habitRecord(let vm): appContainer.makeHabitRecordView(vm: vm)
            case .scheduleRecord(let vm): appContainer.makeScheduleRecordView(vm: vm)
            case .achievementGoal(let goal, let achieveCount): AchivementGoalFullScreen(goal: goal, achiveCount: achieveCount)
        }
    }
}

// MARK: - Navigation Methods
extension Coordinator {
    func push(_ page: Page) { path.append(page) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func backInRoot() { if path.count > 1 { path.removeLast(path.count - 1) } }
    func popToRoot() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            path.removeAll()
        }
    }
    func getCurrentStack() -> Int { path.count }
    
    func openSheet(_ sheet: Sheet) { self.sheet = sheet }
    func dismissSheet() { self.sheet = nil }
    
    func present(_ screen: FullScreenCover) { self.fullScreenCover = screen }
    func dismissScreen() { self.fullScreenCover = nil }
    
    func updateRootState(_ state: AuthState) {
        routerStore.authStore.send(.updateState(state))
    }
    
    func routeToLoginAndReset() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            routerStore.authStore.send(.updateState(.login))
            path.removeAll()
            sheet = nil
            fullScreenCover = nil
        }
    }
    
    func setVisibbleFloatTingState(_ state: Bool) {
        isFloatingButtonVisible = state
    }
    
    func setVisibbleNoGoalPeriodState(_ state: Bool) {
        isNoGoalPeriodVisible = state
    }
}
