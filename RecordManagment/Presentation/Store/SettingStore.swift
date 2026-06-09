import Foundation
import SwiftUI
import Combine

/// 설정 화면에서 사용 할 `Store` 입니다
@MainActor
@Observable
final class SettingStore {
    struct State {
        var name: String = ""
        var originalName: String = ""
        var isValidName: Bool = false
        var birth: Date = .now
        var isShow: Bool = false
        var isAlert: Bool = false
        var method: AuthBox.Escape = .logout
        var systemIsOn: Bool = false
        var totalRecordIsOn: Bool = false
        var isOn: Bool = true               // 목표 미설정 알림
        var dailyIsOn: Bool = true
        var exerciseIsOn: Bool = true
        var habitIsOn: Bool = true
        var scheduleIsOn: Bool = true
        
        var isInitialLoaded: Bool = false
        var isSyncingFromTotal: Bool = false
        var isFadingOutToRoot: Bool = false
        
        var visibleToast: Bool = false
        var toastMessage: String = ""
    }
    
    private(set) var state = State()
    
    // 타 스토어에 상태 반영을 위한 스토어 참조
    let authStore: AuthStore
    let recordStore: RecordStore
    let userStore: UserStore
    let alertStore: AlertStore

    // 의존성
    private let authUseCase: AuthUseCase
    private let settingUseCase: SettingUseCase
    
    private var cancellables = Set<AnyCancellable>()
    private let nameSubject = PassthroughSubject<String, Never>()
    
    init(
        authStore: AuthStore,
        recordStore: RecordStore,
        userStore: UserStore,
        authUseCase: AuthUseCase,
        settingUseCase: SettingUseCase,
        alertStore: AlertStore
    ) {
        self.authStore = authStore
        self.recordStore = recordStore
        self.userStore = userStore
        self.authUseCase = authUseCase
        self.settingUseCase = settingUseCase
        self.alertStore = alertStore
        
        setupNameValidation()
    }
    
    enum Intent {
        case onAppear
        case updateName(String)
        case updateBirthDate(Date)
        case updateIsShow(Bool)
        case updateIsAlert(Bool)
        case updateMethod(AuthBox.Escape)
        case updateToast(visible: Bool, message: String)
        case resetFadeOutState
        
        case toggleTotalRecord(Bool)
        case toggleIsOn(Bool)
        case toggleDaily(Bool)
        case toggleExercise(Bool)
        case toggleHabit(Bool)
        case toggleSchedule(Bool)
        
        case saveNickName
        case saveBirth
        case logout
        case withdraw
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .onAppear:
            initializeData()
            Task { await updateInitToggleState() }
            
        case .updateName(let newName):
            state.name = newName
            nameSubject.send(newName)
            
        case .updateBirthDate(let newBirth):
            state.birth = newBirth
            
        case .updateIsShow(let show):
            state.isShow = show
            
        case .updateIsAlert(let alert):
            state.isAlert = alert
            
        case .updateMethod(let method):
            state.method = method
            
        case .updateToast(let visible, let message):
            state.visibleToast = visible
            state.toastMessage = message
            
        case .resetFadeOutState:
            state.isFadingOutToRoot = false
            
        case .toggleTotalRecord(let isOn):
            guard state.isInitialLoaded else { return }
            state.totalRecordIsOn = isOn
            state.isSyncingFromTotal = true
            state.dailyIsOn = isOn
            state.exerciseIsOn = isOn
            state.habitIsOn = isOn
            state.scheduleIsOn = isOn
            
            let data = NotificationSettingRequestBody(
                dailyRecordNotificationEnabled: isOn,
                exerciseNotificationEnabled: isOn,
                habitNotificationEnabled: isOn,
                scheduleNotificationEnabled: isOn
            )
            Task {
                await fetchRecordNotificationSetting(data: data)
                state.isSyncingFromTotal = false
            }
            
        case .toggleIsOn(let isOn):
            guard state.isInitialLoaded else { return }
            state.isOn = isOn
            let data = NotificationSettingRequestBody(goalSettingNotificationEnabled: isOn)
            Task { await fetchRecordNotificationSetting(data: data) }
            
        case .toggleDaily(let isOn):
            guard state.isInitialLoaded && !state.isSyncingFromTotal else { return }
            state.dailyIsOn = isOn
            updateTotalRecordIsOnIfNeeded()
            let data = NotificationSettingRequestBody(dailyRecordNotificationEnabled: isOn)
            Task { await fetchRecordNotificationSetting(data: data) }
            
        case .toggleExercise(let isOn):
            guard state.isInitialLoaded && !state.isSyncingFromTotal else { return }
            state.exerciseIsOn = isOn
            updateTotalRecordIsOnIfNeeded()
            let data = NotificationSettingRequestBody(exerciseNotificationEnabled: isOn)
            Task { await fetchRecordNotificationSetting(data: data) }
            
        case .toggleHabit(let isOn):
            guard state.isInitialLoaded && !state.isSyncingFromTotal else { return }
            state.habitIsOn = isOn
            updateTotalRecordIsOnIfNeeded()
            let data = NotificationSettingRequestBody(habitNotificationEnabled: isOn)
            Task { await fetchRecordNotificationSetting(data: data) }
            
        case .toggleSchedule(let isOn):
            guard state.isInitialLoaded && !state.isSyncingFromTotal else { return }
            state.scheduleIsOn = isOn
            updateTotalRecordIsOnIfNeeded()
            let data = NotificationSettingRequestBody(scheduleNotificationEnabled: isOn)
            Task { await fetchRecordNotificationSetting(data: data) }
            
        case .saveNickName:
            Task { await updateNickName() }
            
        case .saveBirth:
            Task { await updateBirth() }
            
        case .logout:
            alertStore.send(.logout(
                cancel: {},
                action: {
                    Task { [weak self] in
                        await self?.performLogout()
                    }
                }
            ))
            
        case .withdraw:
            alertStore.send(.withdraw(
                cancel: {},
                action: {
                    Task { [weak self] in
                        await self?.performWithdraw()
                    }
                }
            ))
        }
    }
}

// MARK: - Private Methods

extension SettingStore {
    private func initializeData() {
        if let user = userStore.state.user {
            state.name = user.nickname
            state.originalName = user.nickname
            state.birth = Date.convertDateForIntArray(user.birthDate ?? [])
            ?? Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now
        }
    }
    
    private func setupNameValidation() {
        nameSubject
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { [weak self] name -> Bool in
                guard let self else { return false }
                guard !self.state.originalName.isEmpty else { return false }
                guard name != self.state.originalName else { return false }
                if name.isEmpty { return false }
                guard name.count <= 6 else { return false }
                
                return name.range(of: "^[a-zA-Z0-9가-힣]+$", options: .regularExpression) != nil
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                withAnimation(.smooth) {
                    self?.state.isValidName = isValid
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateTotalRecordIsOnIfNeeded() {
        state.totalRecordIsOn = state.dailyIsOn && state.exerciseIsOn && state.habitIsOn && state.scheduleIsOn
    }
    
    @discardableResult
    private func fetchRecordNotificationSetting(data: NotificationSettingRequestBody) async -> Bool {
        return await settingUseCase.fetch(data: data)
    }
    
    private func updateInitToggleState() async {
        do {
            let data: NotificationSettingData = try await settingUseCase.check()
            
            state.dailyIsOn = data.dailyRecordNotificationEnabled
            state.exerciseIsOn = data.exerciseNotificationEnabled
            state.habitIsOn = data.habitNotificationEnabled
            state.scheduleIsOn = data.scheduleNotificationEnabled
            state.isOn = data.goalSettingNotificationEnabled
            
            if state.dailyIsOn && state.exerciseIsOn && state.habitIsOn && state.scheduleIsOn {
                state.totalRecordIsOn = true
            }
            state.isInitialLoaded = true
        } catch {
            debugPrint("초기값 업데이트 실패 : \(error)")
        }
    }
    
    @discardableResult
    private func updateNickName() async -> Bool {
        do {
            let parameter: [String : Any] = [
                "nickname" : state.name
            ]
            _ = try await settingUseCase.update(with: parameter)
            
            // 성공 시 UserStore 갱신 및 토스트 정보 설정
            userStore.send(.fetchUserRecordType)
            state.originalName = state.name
            state.isValidName = false
            
            state.toastMessage = "닉네임이 변경되었습니다."
            state.visibleToast = true
            return true
        } catch {
            debugPrint("닉네임 업데이트 error : \(error)")
        }
        return false
    }
    
    @discardableResult
    private func updateBirth() async -> Bool {
        // 생일 저장 시 DatePicker 모달 창 닫기
        state.isShow = false
        
        do {
            let parameter: [String : Any] = [
                "birthDate" : Date.onBoardingFormet(state.birth)
            ]
            
            _ = try await settingUseCase.update(with: parameter)
            
            // 성공 시 UserStore 갱신 및 토스트 정보 설정
            userStore.send(.fetchUserRecordType)
            
            state.toastMessage = "생일 정보가 수정되었습니다."
            state.visibleToast = true
            return true
        } catch {
            debugPrint("생일 업데이트 error: \(error)")
        }
        return false
    }
    
    private func performLogout() async {
        _ = await authUseCase.logout()
        state.isFadingOutToRoot = true
    }
    
    private func performWithdraw() async {
        _ = await authUseCase.withdraw()
        state.isFadingOutToRoot = true
    }
}
