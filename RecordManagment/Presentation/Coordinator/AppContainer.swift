import SwiftUI

@MainActor
final class AppContainer {
    
    // MARK: - Shared Stores (상태 공유가 필요한 경우)
    private var sharedAuthStore: AuthStore?
    private var sharedRecordStore: RecordStore?
    private var sharedUserStore: UserStore?
    private var sharedSettingStore: SettingStore?
    private var sharedAlertStore: AlertStore?
    
    // 공사 중
    private var sharedMainVM: MainViewModel?
    private var sharedSheetVM: MainSheetViewModel?
    private var sharedSettingVM: SettingView.ViewModel?
    
    
    // MARK: - Manager
    
    private lazy var keyChain: KeyChainManager = .init()
    private lazy var networkManager :IntergrationManager = .init(service: authService, keyChain: keyChain)
    
    // MARK: - Service
    
    private lazy var authService :AuthService = DefaultAuthService(keyChain: keyChain)
    
    // MARK: - Repositories
    
    private let userRepository: UserRepository = DefaultUserRepository()
    private lazy var calendarRepository: CalendarRepository = DefaultCalendarRepository(
        manager: networkManager,
        keyChain: keyChain
    )
    private lazy var authRepository: AuthRepository = DefaultAuthRepository(
        providers: [
            .kakao: KaKaoAuthProvider(),
            .apple: AppleAuthProvider()
        ],
        authService: authService,
        keyChain: keyChain
    )
    private lazy var scheduleRepository: ScheduleRepository = DefaultScheduleRepository(
        manager: networkManager
    )
    lazy var goalRepository: GoalRepository = DefaultGoalRepository(manager: networkManager)
    lazy var notificationRepository: NotificationRepository = DefaultNotificationRepository(manager: networkManager)
    lazy var onBoardingRepository: OnBoardingRepository = DefaultOnBoardingRepository(manager: networkManager)
    lazy var habitRepository: HabitRepository = DefaultHabitRecordRepository(manager: networkManager)
    lazy var imageRepository: ImageRepository = DefaultImageRepository(manager: networkManager)
    
    // MARK: - UseCases
    lazy var authUseCase: AuthUseCase = DefaultAuthUseCase(repository: authRepository)
    lazy var recordUseCase: RecordUseCase = DefaultRecordUseCase(calendarRepository: calendarRepository)
    lazy var settingUseCase: SettingUseCase = DefaultSettingUseCase(
        userRepository: userRepository,
        goalRepository: goalRepository,
        notificationRepository: notificationRepository
    )
    lazy var calendarUseCase: CalendarUseCase = DefaultCalendarUseCase(repository: calendarRepository)
    lazy var sectionUseCase: SectionOnBoardingUseCase = DefaultSectionOnBoardingUseCase(
        repository: onBoardingRepository,
        goalRepository: goalRepository
    )
    lazy var imageUseCase: ImageUseCase = DefaultImageUseCase(repository: imageRepository)
    
    // MARK: - Store
    
    func makeRouterStore() -> RouterStore {
        let store = RouterStore(
            authStore: makeAuthStore(),
            recordStore: makeRecordStore(),
            userStore: makeUserStore(),
            authUseCase: authUseCase
        )
        return store
    }
    
    func makeAuthStore() -> AuthStore {
        if let shared = sharedAuthStore { return shared }
        let store = AuthStore(authUseCase: authUseCase)
        sharedAuthStore = store
        return store
    }
    
    func makeRecordStore() -> RecordStore {
        if let shared = sharedRecordStore { return shared }
        let store = RecordStore(
            calendarRepository: calendarRepository,
            scheduleRepository: scheduleRepository,
            habitRepository: habitRepository,
            recordUseCase: recordUseCase
        )
        sharedRecordStore = store
        return store
    }
    
    func makeUserStore() -> UserStore {
        if let shared = sharedUserStore { return shared }
        let store = UserStore(userRepository: userRepository)
        sharedUserStore = store
        return store
    }
    
    func makeMainStore() -> MainStore {
        let store = MainStore(
            recordStore: makeRecordStore(),
            userStore: makeUserStore(),
            alertStore: makeAlertStore(),
            scheduleRepository: scheduleRepository,
            goalRepository: goalRepository
        )
        return store
    }
    
    func makeNotificationStore() -> NotificationStore {
        let store = NotificationStore(
            recordStore: makeRecordStore(),
            userStore: makeUserStore(),
            repository: notificationRepository
        )
        return store
    }
    
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
            habitRepository: habitRepository,
            calendarUseCase: calendarUseCase,
            mainVM: makeMainViewModel(),
            scheduleRepository: scheduleRepository
        )
        sharedSheetVM = vm
        sharedSheetVM?.fetchRecordLimit()
        return vm
    }
    
    func makeScheduleViewModel(scheduleResponse: ScheduleResponse? = nil) -> ScheduleViewModel {
        ScheduleViewModel(
            repository: scheduleRepository,
            scheduleResponse: scheduleResponse
        )
    }
    
    func makeSettingViewModel() -> SettingView.ViewModel {
        if let shared = sharedSettingVM { return shared }
        let vm = SettingView.ViewModel(
            useCase: settingUseCase,
            mainVM: makeMainViewModel(),
            authUseCase: authUseCase
        )
        sharedSettingVM = vm
        return vm
    }
    
    func makeSettingStore() -> SettingStore {
        if let shared = sharedSettingStore { return shared }
        let store = SettingStore(
            authStore: makeAuthStore(),
            recordStore: makeRecordStore(),
            userStore: makeUserStore(),
            authUseCase: authUseCase,
            settingUseCase: settingUseCase,
            alertStore: makeAlertStore()
        )
        sharedSettingStore = store
        return store
    }
    
    func makeAlertStore() -> AlertStore {
        if let shared = sharedAlertStore { return shared }
        let store = AlertStore()
        sharedAlertStore = store
        return store
    }
    
    func makeOnBoardingStore(firstOnBoarding: Bool = true) -> OnBoardingStore {
        let store = OnBoardingStore(
            useCase: sectionUseCase,
            authStore: makeAuthStore(),
            firstOnBoarding: firstOnBoarding
        )
        return store
    }
    
    func makeNotificationViewModel() -> NotificationView.ViewModel {
        return NotificationView.ViewModel(
            useCase: DefaultNotificationUseCase(
                repository: notificationRepository
            )
        )
    }
    
    // MARK: - View Factories
    
    func makeSocialView() -> some View {
        SocialView()
            .environment(makeAuthStore())
    }
    
    func makeMainView() -> some View {
        MainView(store: makeMainStore())
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
    
    func makeScheduleRecordView(scheduleResponse: ScheduleResponse? = nil) -> some View {
        ScheduleView(
            vm: makeScheduleViewModel(scheduleResponse: scheduleResponse),
            sheetVM: makeMainSheetViewModel()
        )
    }
    
    func makeSettingView() -> some View {
        SettingView(store: makeSettingStore())
    }
    
    func makeNotificationView() -> some View {
        NotificationView(
            store: makeNotificationStore()
        )
    }
    
    func makeNickNameChangeView() -> some View {
        NickNameChangeView(store: makeSettingStore())
    }
    
    func makeAppNoticeView() -> some View {
        AppNoticeView(vm: makeSettingViewModel())
    }
    
    func makeRecordNoticeView() -> some View {
        RecordNoticeView(vm: makeSettingViewModel())
    }
    
    func makeSectionView() -> some View {
        SectionView(store: makeOnBoardingStore(firstOnBoarding: true))
    }
    
    func makeFinalOnBoardingView(toastMessage: String?) -> some View {
        FinalOnBoardingView(
            store: makeOnBoardingStore(),
            toastMessage: toastMessage
        )
    }
    
    func makeGoalReSelectionView() -> some View {
        GoalReSelection(store: makeOnBoardingStore(firstOnBoarding: false))
    }
    
    func makeScheduleNotificationSheet(
        notificationBinding: Binding<ScheduleNotification>,
        _ saveStateBinding: Binding<SaveState>
    ) -> some View {
        ScheduleNotificationSheet(
            notification: notificationBinding,
            saveState: saveStateBinding
        )
    }
    
    func makeScheduleRepeatSheet(
        repeatBinding: Binding<ScheduleRepeat>,
        _ saveStateBinding: Binding<SaveState>
    ) -> some View {
        ScheduleRepeatSheet(
            repeatData: repeatBinding,
            saveState: saveStateBinding
        )
    }
    
    func makeScheduleColorSheet(
        colorBinding: Binding<ScheduleColor>,
        _ saveStateBinding: Binding<SaveState>
    ) -> some View {
        ScheduleColorSheet(
           color: colorBinding,
           saveState: saveStateBinding
        )
    }
}
