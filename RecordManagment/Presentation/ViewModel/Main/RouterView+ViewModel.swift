import Foundation

extension RouterView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var currentState: UserState = .initialize
        @Published var showAlert: Bool = false
        @Published var alertMessage: String = ""
        
        let useCase: RouterUseCase
        
        init(useCase: RouterUseCase) {
            self.useCase = useCase
        }
        
        // TODO: 자동 로그인 함수
        
        func autoLogin() async -> UserState {
            return await useCase.autoLogin { // refreshToken 만료의 경우
                Task { @MainActor in
                    showAlert = true
                    alertMessage = "다시 로그인 해주세요"
                    _ = await useCase.logout()
                }
            }
        }
        
        // TODO: 로그아웃
        func logout() async {
            let result = await useCase.logout() // return bool
            
            if result {
                currentState = .login
            }
        }
        
        func withdraw() async {
            let result = await useCase.withdraw()
            
            if result {
                currentState = .login
            }
        }
        
        func achieveGoal(userId: String) async -> GoalAchieve? {
            do {
                return try await useCase.achive(userId: userId)
            } catch {
                debugPrint("목표 달성 보고서 Fetch Error : \(error)")
            }
            
            return nil
        }
    }
}
