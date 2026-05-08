import SwiftUI

@MainActor
final class AppContainer {
    
    // MARK: - Shared ViewModels (상태 유지가 필요한 경우)
    
    private var sharedMainVM: MainViewModel?
    private var sharedSheetVM: MainSheetViewModel?
    private var sharedSettingVM: SettingView.ViewModel?
    private var sharedSectionVM: SectionView.ViewModel?
    private var sharedRouterVM: RouterView.ViewModel?
    
    // MARK: - Repositories
    
    private let userRepository: UserRepository = DefaultUserRepository()
    private let recordRepository: RecordRepository = DefaultRecordRepository()
    private let settingRepository: SettingRepository = DefaultSettingRepository()
    private let calendarRepository: CalendarRepository = DefaultCalendarRepository()
    private let mainSheetRepository: MainSheetRepository = DefaultMainSheetRepository()
    private let routerRepository: RouterRepository = DefaultRouterRepository()
    
    // MARK: - UseCases
    
    private lazy var recordUseCase: RecordUseCase = DefaultRecordUseCase(repository: recordRepository)
    private lazy var settingUseCase: SettingUseCase = DefaultSettingUseCase(repository: settingRepository)
    private lazy var calendarUseCase: CalendarUseCase = DefaultCalendarUseCase(repository: calendarRepository)
    private lazy var sectionUseCase: SectionOnBoardingUseCase = DefaultSectionOnBoardingUseCase(repository: DefaultSectionRepository())
    private lazy var mainSheetUseCase: MainSheetUseCase = DefaultMainSheetUseCase(
        repository: mainSheetRepository
    )
    
    // MARK: - ViewModel Factories
    
    func makeMainViewModel() -> MainViewModel {
        if let shared = sharedMainVM { return shared }
        let vm = MainViewModel(
            userRepository: userRepository,
            recordUseCase: recordUseCase,
            settingUseCase: settingUseCase
        )
        sharedMainVM = vm
        return vm
    }
    
    func makeMainSheetViewModel() -> MainSheetViewModel {
        if let shared = sharedSheetVM { return shared }
        let vm = MainSheetViewModel(
            useCase: mainSheetUseCase,
            calendarUseCase: calendarUseCase,
            mainVM: makeMainViewModel()
        )
        sharedSheetVM = vm
        return vm
    }
    
    func makeRouterViewModel() -> RouterView.ViewModel {
        if let shared = sharedRouterVM { return shared }
        let vm = RouterView.ViewModel(repository: routerRepository)
        sharedRouterVM = vm
        return vm
    }
    
    func makeSettingViewModel() -> SettingView.ViewModel {
        if let shared = sharedSettingVM { return shared }
        let vm = SettingView.ViewModel(
            useCase: DefaultSettingUseCase(repository: settingRepository),
            mainVM: makeMainViewModel(),
            routerRepository: routerRepository
        )
        sharedSettingVM = vm
        return vm
    }
    
    func makeSectionViewModel(firstOnBoarding: Bool = true) -> SectionView.ViewModel {
        if let shared = sharedSectionVM { 
            shared.firstOnBoarding = firstOnBoarding
            return shared 
        }
        let vm = SectionView.ViewModel(
            useCase: sectionUseCase,
            firstOnBoarding: firstOnBoarding
        )
        sharedSectionVM = vm
        return vm
    }
    
    func makeNotificationViewModel() -> NotificationView.ViewModel {
        return NotificationView.ViewModel(
            useCase: DefaultNotificationUseCase(
                repository: DefaultNotificationRepository()
            )
        )
    }
    
    // MARK: - View Factories
    
    func makeMainView() -> some View {
        MainView(
            mainVM: makeMainViewModel(),
            sheetVM: makeMainSheetViewModel()
        )
    }
    
    func makeRecordSelectionView() -> some View {
        RecordSelectionView(
            mainVM: makeMainViewModel(),
            sheetVM: makeMainSheetViewModel()
        )
    }
    
    func makeDayRecordView(emotion: EmotionObj) -> some View {
        DayRecordView(
            emotion: emotion,
            sheetVM: makeMainSheetViewModel()
        )
    }
    
    func makeDayRecordEditView(dailyInfo: DailyResponse) -> some View {
        DayRecordView(
            dailyInfo: dailyInfo,
            sheetVM: makeMainSheetViewModel()
        )
    }
    
    func makeExerciseRecordView(exercise: ExerciseObj) -> some View {
        ExerciseRecordView(
            exercise: exercise,
            sheetVM: makeMainSheetViewModel()
        )
    }
    
    func makeExerciseRecordEditView(exerciseInfo: ExerciseResponse) -> some View {
        ExerciseRecordView(
            exerciseInfo: exerciseInfo,
            sheetVM: makeMainSheetViewModel()
        )
    }
    
    func makeHabitRecordView(habit: HabitObj) -> some View {
        HabitRecordView(
            habit: habit,
            mainVM: makeMainViewModel(),
            sheetVM: makeMainSheetViewModel()
        )
    }
    
    func makeHabitRecordEditView(habitInfo: HabitResponse) -> some View {
        HabitRecordView(
            habitInfo: habitInfo,
            mainVM: makeMainViewModel(),
            sheetVM: makeMainSheetViewModel()
        )
    }
    
    func makeSettingView() -> some View {
        SettingView(
            mainVM: makeMainViewModel(),
            sheetVM: makeMainSheetViewModel(),
            vm: makeSettingViewModel()
        )
    }
    
    func makeNotificationView() -> some View {
        NotificationView(
            mainVM: makeMainViewModel(),
            sheetVM: makeMainSheetViewModel(),
            vm: makeNotificationViewModel()
        )
    }
    
    func makeNickNameChangeView() -> some View {
        NickNameChangeView(
            vm: makeSettingViewModel(),
            sheetVM: makeMainSheetViewModel()
        )
    }
    
    func makeAppNoticeView() -> some View {
        AppNoticeView(vm: makeSettingViewModel())
    }
    
    func makeRecordNoticeView() -> some View {
        RecordNoticeView(vm: makeSettingViewModel())
    }
    
    func makeSectionView() -> some View {
        SectionView(vm: makeSectionViewModel(firstOnBoarding: true))
    }
    
    func makeFinalOnBoardingView(toastMessage: String?) -> some View {
        FinalOnBoardingView(
            vm: makeSectionViewModel(),
            toastMessage: toastMessage
        )
    }
    
    func makeGoalReSelectionView() -> some View {
        GoalReSelection(vm: makeSectionViewModel(firstOnBoarding: false))
    }
    
    func resetSectionViewModel() {
        sharedSectionVM = nil
    }
}
