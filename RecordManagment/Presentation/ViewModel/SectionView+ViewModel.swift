import SwiftUI
import Combine

extension SectionView {
    
    @MainActor
    class ViewModel: ObservableObject {
        @Published var currentProgress: ProgressPage = .record
        @Published var currentPage: GoalReSelection.CurrentPage = .record // 재설정 Pregress Page
        @Published var currentRecord: Record = .none
        @Published var name: String = ""
        @Published var isValidName: Bool = false
        @Published var selectGoal: SectionFourView.GoalTypes = .none
        @Published var isGrant: Bool? = nil
        @Published var selectedDate: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now
        @Published var isGrantAlert: Bool = false
        @Published var firstOnBoarding: Bool
        @Published var birthPartSkip: Bool = false
        
        let noticeService: NotificationService = .shared
        let useCase: SectionOnBoardingUseCase
        init(useCase: SectionOnBoardingUseCase, firstOnBoarding: Bool = true) {
            self.useCase = useCase
            self.firstOnBoarding = firstOnBoarding
            // TODO: NAME Subscriber 선언
            if firstOnBoarding {
                getNameSubscriber()
            }
        }
        
        private var cancellables: Set<AnyCancellable> = []
        
        // TODO: 온보딩 Name 부분 구독 함수
        private func getNameSubscriber() {
            getNamePublisher()
                .sink { [weak self] val in
                    withAnimation(.smooth) {
                        self?.isValidName = val
                    }
                }
                .store(in: &cancellables)
        }
        
        // TODO: 온보딩 Name 부분 Publisher 함수
        private func getNamePublisher() -> AnyPublisher<Bool,Never> {
            $name
                .debounce(for: 0.2, scheduler: RunLoop.main)
                .map { name -> Bool in
                    if name.isEmpty { return false }
                    guard name.count <= 6 else { return false }
                    
                    return name.range(of: "^[a-zA-Z0-9가-힣]+$", options: .regularExpression) != nil
                }
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        
        
        // TODO: Notification 권한 허용 함수
        func requestPermisson() async -> Bool {
             let grant = await noticeService.requestNotificationPermission()
             return grant
        }
        
        // TODO: 앱 설정에서 권한 허용 시점에 grant 변경
        func checkPermission() async {
            let grant = await noticeService.getNotificationAuthorizationStatus()
            switch grant {
                case .authorized, .provisional, .ephemeral:
                    self.isGrant = true
                default:
                    self.isGrant = false
            }
        }
        
        // TODO: 앱 권한이 없을 경우 앱 세팅으로 보내는 함수
        func moveAppSetting() async {
            await noticeService.openAppSettings()
        }
        
        // TODO: OnBoarding 전달 함수
        func completeOnBoarding() async -> UserState {
            guard let onBoarding = await makeOnBoardingDTO() else { return .register }
            let result = await useCase.onBoardingFetchingComplete(dto: onBoarding)
            
            switch result {
                case .success(let success):
                    debugPrint(success)
                    return .main
                case .failure(let failure):
                    debugPrint(failure)
                    return .register
            }
        }
        
        // TODO: 온보딩 객체 생성 함수
        func makeOnBoardingDTO() async -> OnBoardingDTO? {
            return OnBoardingDTO(
                nickName: name,
                mainRecordType: currentRecord.localizedString(),
                birthDate: birthPartSkip ? nil : Date.onBoardingFormet(selectedDate),
                goalDays: selectGoal.localizedInt(),
            )
        }
    }
}


// MARK: 온보딩 목표 재설정 함수 모음
extension SectionView.ViewModel {
    // TODO: 온보딩 재설정 Fetch 함수
    func onBoardingReSelection() async -> Bool {
        let form = await makeReSelectionGoal()
        let result = await useCase.reSelectionOnBoarding(dto: form)
        
        switch result {
            case .success(_):
                AnalyticsManager.shared.logGoalResetComplete(form.recordType, goalDays: form.goalDays)
                return true
            case .failure(let err):
                debugPrint("온보딩 재설정 실패 Error : \(err)")
                return false
        }
    }
    
    func makeReSelectionGoal() async -> GoalReSelectionRequestBody {
        GoalReSelectionRequestBody(
            recordType: self.currentRecord.localizedString(),
            goalDays: self.selectGoal.localizedInt()
        )
    }
}
