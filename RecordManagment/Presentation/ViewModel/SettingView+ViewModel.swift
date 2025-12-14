import SwiftUI
import Combine

extension SettingView {
    @MainActor
    class ViewModel: ObservableObject {
        @ObservedObject var resVM: RecordSelectionView.ViewModel
        @Published var name: String
        @Published var isValidName: Bool = false
        @Published var birth: Date
        @Published var isShow: Bool = false
        @Published var isAlert: Bool = false
        @Published var method: AuthBox.Escape = .logout
        @Published var systemIsOn: Bool = false
        @Published var totalRecordIsOn: Bool = false
        @Published var isOn: Bool = true               // 목표 미설정 알림
        @Published var dailyIsOn: Bool = true
        @Published var exerciseIsOn: Bool = true
        @Published var habitIsOn: Bool = true
        @Published private var isInitialLoaded = false
        @Published private var isSyncingFromTotal = false
        
        private var cancellables = Set<AnyCancellable>()
        var originalName: String = ""
        let useCase: SettingUseCase
        
        init(useCase: SettingUseCase,resVM: RecordSelectionView.ViewModel) {
            self.useCase = useCase
            self.resVM = resVM
            // Name
            name = resVM.user.data?.nickname ?? ""
            originalName = resVM.user.data?.nickname ?? "" // 임시 저장
            birth = Date.convertDateForIntArray(resVM.user.data?.birthDate ?? []) ?? .now
            Task {
                await updateInitToggleState()
            }
            // NickName Subscriber
            getNameSubscriber()
            // 앱 목표 미설정 알림
            getIsOnBinding()
            // 기록별 알림
            getTotalRecordIsOnBinding() // totalRecordIsOn Binding
            getDailyIsOnBinding()       // dailyIsOn Binding
            getExerciseIsOnBinding()    // exerciseIsOn Binding
            getHabitIsOnBinding()       // habitIsOn Binding
        }
    }
}


// MARK: Combine name, isValidName
extension SettingView.ViewModel {
    // TODO: 설정 Name 부분 구독 함수
    private func getNameSubscriber() {
        getNamePublisher()
            .sink { [weak self] val in
                withAnimation(.smooth) {
                    self?.isValidName = val
                }
            }
            .store(in: &cancellables)
    }
    
    // TODO: 설정 Name 부분 Publisher 함수
    private func getNamePublisher() -> AnyPublisher<Bool,Never> {
        $name
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { name -> Bool in
                guard !self.originalName.isEmpty else { return false }
                guard name != self.originalName else { return false }
                if name.isEmpty { return false }
                guard name.count <= 6 else { return false }
                
                return name.range(of: "^[a-zA-Z0-9가-힣]+$", options: .regularExpression) != nil
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}


// MARK: Profile Update
extension SettingView.ViewModel {
    func updateNickName() async -> Bool {
        do {
            let parameter: [String : Any] = [
                "nickname" : name
            ]
            let currentUser = try await useCase.update(with: parameter)
            resVM.user = currentUser
            originalName = self.name
            return true
        } catch {
            debugPrint("닉네임 업데이트 error : \(error)")
        }
        return false
    }
    
    func updateBirth() async -> Bool {
        do {
            let parameter: [String : Any] = [
                "birthDate" : Date.onBoardingFormet(birth)
            ]
            
            let currentUser = try await useCase.update(with: parameter)
            resVM.user = currentUser
            
            return true
        } catch {
            debugPrint("생일 업데이트 error: \(error)")
        }
        return false
    }
}


// MARK: TotalRecord Combine
extension SettingView.ViewModel {
    // totalRecordIsOn이 true면 전체 true and false
    func getTotalRecordIsOnBinding() {
        $totalRecordIsOn
            .receive(on: RunLoop.main)
            .map { $0 }
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] val in
                guard let self,self.isInitialLoaded else { return } // 초기화 중엔 무시
                self.isSyncingFromTotal = true
                self.dailyIsOn = val
                self.exerciseIsOn = val
                self.habitIsOn = val
                
                let data = NotificationSettingRequestBody(
                    dailyRecordNotificationEnabled: val,
                    exerciseNotificationEnabled: val,
                    habitNotificationEnabled: val
                )

                Task {
                    await self.fetchRecordNotificationSetting(data: data)
                }
                
                Task {
                    await MainActor.run {
                        self.isSyncingFromTotal = false
                    }
                }
            })
            .store(in: &cancellables)
    }
}

// MARK: Record Notifiaction Combine
extension SettingView.ViewModel {
    
    func getIsOnBinding() {
        $isOn
            .dropFirst()
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .map { $0 }
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] val in
                guard let self, self.isInitialLoaded else { return } // 초기화 중엔 무시
                debugPrint("isOn : \(val)")
                let data = NotificationSettingRequestBody(goalSettingNotificationEnabled: val)
                Task {
                    await self.fetchRecordNotificationSetting(data: data)
                }
            })
            .store(in: &cancellables)
    }
    
    func getDailyIsOnBinding() {
        $dailyIsOn
            .dropFirst()
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .map { $0 }
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] val in
                guard let self, self.isInitialLoaded, !self.isSyncingFromTotal else { return } // 초기화 중엔 무시
                debugPrint("daily : \(val)")
                let data = NotificationSettingRequestBody(dailyRecordNotificationEnabled: val)
                Task {
                    await self.fetchRecordNotificationSetting(data: data)
                }
            })
            .store(in: &cancellables)
    }
    
    func getExerciseIsOnBinding() {
        $exerciseIsOn
            .dropFirst()
            .removeDuplicates()
            .map { $0 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] val in
                guard let self, self.isInitialLoaded,!self.isSyncingFromTotal else { return } // 초기화 중엔 무시
                debugPrint("exercise : \(val)")
                let data = NotificationSettingRequestBody(exerciseNotificationEnabled: val)
                Task {
                    await self.fetchRecordNotificationSetting(data: data)
                }
            })
            .store(in: &cancellables)
    }
    
    func getHabitIsOnBinding() {
        $habitIsOn
            .dropFirst()
            .removeDuplicates()
            .map { $0 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] val in
                guard let self, self.isInitialLoaded,!self.isSyncingFromTotal else { return } // 초기화 중엔 무시
                debugPrint("habit : \(val)")
                let data = NotificationSettingRequestBody(habitNotificationEnabled: val)
                Task {
                    await self.fetchRecordNotificationSetting(data: data)
                }
            })
            .store(in: &cancellables)
    }
}

// MARK: Data Fetch Extension
extension SettingView.ViewModel {
    
    @discardableResult
    func fetchRecordNotificationSetting(data: NotificationSettingRequestBody) async -> Bool {
        return await useCase.fetch(data: data)
    }
    
    func updateInitToggleState() async {
        do {
            let data: NotificationSettingData = try await useCase.check()
            
            dailyIsOn = data.dailyRecordNotificationEnabled
            exerciseIsOn = data.exerciseNotificationEnabled
            habitIsOn = data.habitNotificationEnabled
            isOn = data.goalSettingNotificationEnabled
            
            if dailyIsOn && exerciseIsOn && habitIsOn {
                totalRecordIsOn = true
            }
            await MainActor.run {
                self.isInitialLoaded = true
            }
        } catch {
            debugPrint("초기값 업데이트 실패 : \(error)")
        }
    }
    
    // MARK TEST Code
    func testGoalInit() async {
        do {
            try await useCase.test()
        } catch {
            debugPrint("error: \(error)")
        }
    }
}
