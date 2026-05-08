import Foundation

extension RouterView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var currentState: UserState = .initialize
        @Published var showAlert: Bool = false
        @Published var alertMessage: String = ""
        @Published var isGoalChecked: Bool = false // 보고서 체크 여부 플래그 추가
        
        let repository: RouterRepository
        
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
