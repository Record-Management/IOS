import SwiftUI

// MARK: - Hashable Conformances for ViewModels

extension SectionView.ViewModel: Hashable {
    nonisolated public static func == (lhs: SectionView.ViewModel, rhs: SectionView.ViewModel) -> Bool {
        lhs === rhs
    }
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

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
    case dailyRecordEdit(dailyInfo: DailyResponse)
    case exerciseRecordEdit(exerciseInfo: ExerciseResponse)
    case habitRecordEdit(habitInfo: HashableHabitResponse)
    case setting
    case appNotice
    case recordNotice
    case notification
    case goalSelection
    
    var id: Int { self.hashValue }
}

typealias HashableHabitResponse = HabitResponse

enum Sheet: Identifiable, Hashable {
    case nickName
    
    var id: Int { self.hashValue }
}

enum FullScreenCover: Identifiable, Hashable {
    case recordSelection
    case dailyRecord(emotion: EmotionObj)
    case exerciseRecord(exercise: ExerciseObj)
    case habitRecord(habit: HabitObj)
    case achievementGoal(goal: RecentHistoryData, achiveCount: Int)
    
    var id: Int { self.hashValue }
}

// MARK: - Coordinator

@MainActor
final class Coordinator: ObservableObject {
    @Published var path: [Page] = []
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    
    let appContainer: AppContainer
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }
    
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
            case .root: RouterView(rm: appContainer.makeRouterViewModel())
            case .admin: AdministrationView()
            case .login: SocialView()
            case .term: TermsOfUseView()
            case .section: appContainer.makeSectionView()
            case .finalOnBoarding(let message): appContainer.makeFinalOnBoardingView(toastMessage: message)
            case .main: appContainer.makeMainView()
            case .notification: appContainer.makeNotificationView()
            case .setting: appContainer.makeSettingView()
            case .dailyRecordEdit(let dailyInfo): appContainer.makeDayRecordEditView(dailyInfo: dailyInfo)
            case .exerciseRecordEdit(let exerciseInfo): appContainer.makeExerciseRecordEditView(exerciseInfo: exerciseInfo)
            case .habitRecordEdit(let habitInfo): appContainer.makeHabitRecordEditView(habitInfo: habitInfo)
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
            case .dailyRecord(let emotion): appContainer.makeDayRecordView(emotion: emotion)
            case .exerciseRecord(let exercise): appContainer.makeExerciseRecordView(exercise: exercise)
            case .habitRecord(let habit): appContainer.makeHabitRecordView(habit: habit)
            case .achievementGoal(let goal, let achieveCount): AchivementGoalFullScreen(goal: goal, achiveCount: achieveCount)
        }
    }
}

// MARK: - Navigation Methods
extension Coordinator {
    func push(_ page: Page) { path.append(page) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func backInRoot() { if path.count > 1 { path.removeLast(path.count - 1) } }
    func popToRoot() { path.removeLast(path.count) }
    func getCurrentStack() -> Int { path.count }
    
    func openSheet(_ sheet: Sheet) { self.sheet = sheet }
    func dismissSheet() { self.sheet = nil }
    
    func present(_ screen: FullScreenCover) { self.fullScreenCover = screen }
    func dismissScreen() { self.fullScreenCover = nil }
}
