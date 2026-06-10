import SwiftUI

@MainActor
final class AppContainer {
    
    // MARK: - Shared Stores (상태 공유가 필요한 경우)
    private var sharedAuthStore: AuthStore?
    private var sharedRecordStore: RecordStore?
    private var sharedUserStore: UserStore?
    private var sharedAlertStore: AlertStore?
    private var sharedNotificationStore: NotificationStore?
    
    
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
    lazy var habitRepository: any HabitRepository = DefaultHabitRecordRepository(manager: networkManager)
    lazy var dailyRepository: any RecordRepository = DefaultDailyRecordRepository(manager: networkManager)
    lazy var exerciseRepository: any RecordRepository = DefaultExerciseRecordRepository(manager: networkManager)
    lazy var imageRepository: ImageRepository = DefaultImageRepository(manager: networkManager)
    
    // MARK: - UseCases
    lazy var authUseCase: AuthUseCase = DefaultAuthUseCase(repository: authRepository)
    lazy var recordUseCase: RecordUseCase = DefaultRecordUseCase(calendarRepository: calendarRepository)
    lazy var settingUseCase: SettingUseCase = DefaultSettingUseCase(
        userRepository: userRepository,
        goalRepository: goalRepository,
        notificationRepository: notificationRepository
    )
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
            dailyRepository: dailyRepository,
            exerciseRepository: exerciseRepository
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
        if let shared = sharedNotificationStore { return shared }
        let store = NotificationStore(
            recordStore: makeRecordStore(),
            userStore: makeUserStore(),
            repository: notificationRepository
        )
        sharedNotificationStore = store
        return store
    }
    
    // MARK: - ViewModel Factories
    
    func makeDayRecordViewModel(emotion: EmotionObj) -> DayRecordView.ViewModel {
        DayRecordView.ViewModel(
            emotion: emotion,
            imageUseCase: imageUseCase,
            method: .create,
            repository: DefaultDailyRecordRepository(manager: networkManager)
        )
    }
    
    func makeDayRecordEditViewModel(dailyInfo: DailyResponse) -> DayRecordView.ViewModel {
        var component = DateComponents(
            year: dailyInfo.base.recordDate[0],
            month: dailyInfo.base.recordDate[1],
            day: dailyInfo.base.recordDate[2],
            hour: dailyInfo.base.recordTime?[0],
            minute: dailyInfo.base.recordTime?[1]
        )
        component.calendar = Calendar.current
        return DayRecordView.ViewModel(
            recordId: dailyInfo.base.id,
            emotion: EmotionObj.matchingEmotion(dailyInfo.emotion),
            text: dailyInfo.content,
            serverImageUrls: dailyInfo.imageUrls.compactMap { URL(string: $0) },
            date: component.date ?? .now,
            imageUseCase: imageUseCase,
            method: .update,
            repository: DefaultDailyRecordRepository(manager: networkManager)
        )
    }
    
    func makeExerciseRecordViewModel(exercise: ExerciseObj) -> ExerciseRecordView.ViewModel {
        ExerciseRecordView.ViewModel(
            exercise: exercise,
            imageUseCase: imageUseCase,
            method: .create,
            repository: DefaultExerciseRecordRepository(manager: networkManager)
        )
    }
    
    func makeExerciseRecordEditViewModel(exerciseInfo: ExerciseResponse) -> ExerciseRecordView.ViewModel {
        ExerciseRecordView.ViewModel(
            exerciseInfo: exerciseInfo,
            selectedDate: .constant(nil),
            imageUseCase: imageUseCase,
            method: .update,
            repository: DefaultExerciseRecordRepository(manager: networkManager)
        )
    }
    
    func makeHabitRecordViewModel(habit: HabitObj) -> HabitRecordView.ViewModel {
        HabitRecordView.ViewModel(
            habit: habit,
            method: .create,
            repository: DefaultHabitRecordRepository(manager: networkManager)
        )
    }
    
    func makeHabitRecordEditViewModel(habitInfo: HabitResponse) -> HabitRecordView.ViewModel {
        HabitRecordView.ViewModel(
            habitInfo: habitInfo,
            method: .update,
            repository: DefaultHabitRecordRepository(manager: networkManager)
        )
    }
    
    func makeScheduleViewModel(scheduleResponse: ScheduleResponse? = nil) -> ScheduleViewModel {
        ScheduleViewModel(
            repository: scheduleRepository,
            scheduleResponse: scheduleResponse
        )
    }
    
    func makeScheduleRecordEditViewModel(schedule: ScheduleDetail) -> ScheduleViewModel {
        ScheduleViewModel(
            repository: scheduleRepository,
            scheduleDetail: schedule
        )
    }
    
    func makeSettingStore() -> SettingStore {
        let store = SettingStore(
            authStore: makeAuthStore(),
            recordStore: makeRecordStore(),
            userStore: makeUserStore(),
            authUseCase: authUseCase,
            settingUseCase: settingUseCase,
            alertStore: makeAlertStore()
        )
        return store
    }
    
    func makeAlertStore() -> AlertStore {
        if let shared = sharedAlertStore { return shared }
        let store = AlertStore()
        sharedAlertStore = store
        return store
    }
    
    func makeOnBoardingStore(firstOnBoarding: Bool? = nil) -> OnBoardingStore {
        if let firstOnBoarding = firstOnBoarding {
            // 명시적으로 firstOnBoarding 값을 줄 때는 새로운 세션이 시작된 것이므로 스토어를 재생성합니다.
            let store = OnBoardingStore(
                useCase: sectionUseCase,
                authStore: makeAuthStore(),
                firstOnBoarding: firstOnBoarding
            )
            return store
        }
        
        let store = OnBoardingStore(
            useCase: sectionUseCase,
            authStore: makeAuthStore(),
            firstOnBoarding: true
        )
        return store
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
            userStore: makeUserStore()
        )
    }
    
    func makeDayRecordView(vm: DayRecordView.ViewModel) -> some View {
        DayRecordView(
            vm: vm
        )
    }
    
    func makeDayRecordEditView(vm: DayRecordView.ViewModel) -> some View {
        DayRecordView(
            vm: vm
        )
    }
    
    func makeExerciseRecordView(vm: ExerciseRecordView.ViewModel) -> some View {
        ExerciseRecordView(
            vm: vm
        )
    }
    
    func makeExerciseRecordEditView(vm: ExerciseRecordView.ViewModel) -> some View {
        ExerciseRecordView(
            vm: vm
        )
    }
    
    func makeHabitRecordView(vm: HabitRecordView.ViewModel) -> some View {
        HabitRecordView(
            vm: vm,
            userStore: makeUserStore(),
            recordStore: makeRecordStore()
        )
    }
    
    func makeHabitRecordEditView(vm: HabitRecordView.ViewModel) -> some View {
        HabitRecordView(
            vm: vm,
            userStore: makeUserStore(),
            recordStore: makeRecordStore()
        )
    }
    
    func makeScheduleRecordView(vm: ScheduleViewModel) -> some View {
        ScheduleView(
            vm: vm
        )
    }
    
    func makeScheduleRecordEditView(vm: ScheduleViewModel) -> some View {
        ScheduleView(
            vm: vm
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
        AppNoticeView(store: makeSettingStore())
    }
    
    func makeRecordNoticeView() -> some View {
        RecordNoticeView(store: makeSettingStore())
    }
    
    func makeSectionView() -> some View {
        SectionView(store: makeOnBoardingStore(firstOnBoarding: true))
    }
    
    func makeFinalOnBoardingView(store: OnBoardingStore, toastMessage: String?) -> some View {
        FinalOnBoardingView(
            store: store,
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
