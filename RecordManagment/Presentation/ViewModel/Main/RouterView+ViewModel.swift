import Foundation

extension RouterView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var currentState: UserState = .initialize
        @Published var showAlert: Bool = false
        @Published var alertMessage: String = ""
        @Published var isGoalChecked: Bool = false // 보고서 체크 여부 플래그 추가
        
        private let repository: RouterRepository
        
        init(repository: RouterRepository) {
            self.repository = repository
        }
        
        // TODO: 자동 로그인 함수
        
        func autoLogin() async -> UserState {
            return await repository.refreshLogin { // refreshToken 만료의 경우
                Task { @MainActor in
                    showAlert = true
                    alertMessage = "다시 로그인 해주세요"
                    _ = await repository.logout()
                }
            }
        }
        
        // MARK: 자동 로그인 기능 ( AccessToken 갱신 )
//        func autoLogin(completion: () -> Void) async -> UserState {
//            // login 실행
//            let result = await authorizationToken()
//            switch result {
//                case .success(let res):
//                    debugPrint("자동 로그인 성공 : \(res.statusCode)")
//                    switch res.statusCode {
//                    case 200: // 기존 사용자
//                        if let user = res.data?.user {
//                            if user.onboardingCompleted {
//                                debugPrint("자동 로그인 : 온보딩을 완료한 자!")
//                                return .main
//                            }else {
//                                debugPrint("자동 로그인 : 온보딩 해야지!")
//                                return .register
//                            }
//                        }
//                    default:  // 이상한 경로
//                        return .login
//                    }
//                case .failure(let err):
//                    switch err {
//                        case .refreshTokenExpired:
//                            debugPrint("refresh 만료되었으므로 로그인으로 이동!!!")
//                            completion() // message alert 주는 Closer
//                        default:
//                            debugPrint("자동 로그인 err : \(err)")
//                    }
//            }
//            return .login
//        }
        
        // TODO: 로그아웃
        func logout() async {
            let result = await repository.logout() // return bool
            
            if result {
                currentState = .login
                isGoalChecked = false // 로그아웃 시 플래그 리셋
            }
        }
        
        func withdraw() async {
            let result = await repository.withdraw()
            
            if result {
                currentState = .login
                isGoalChecked = false // 탈퇴 시 플래그 리셋
            }
        }
        
        func achieveGoal(userId: String) async -> GoalAchieve? {
            do {
                return try await repository.fetchReport(id: userId).get()
            } catch {
                debugPrint("목표 달성 보고서 Fetch Error : \(error)")
            }
            
            return nil
        }
    }
}
