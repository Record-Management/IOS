import Foundation

extension RouterView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var currentState: UserState = .initialize
        @Published var showAlert: Bool = false
        @Published var alertMessage: String = ""
        let networkManager = LoginNetworkManager()
        
        // TODO: 자동 로그인 함수
        func autoLogin() async {
            self.currentState = await networkManager.autoLogin() { // refreshToken 만료의 경우
                Task { @MainActor in
                    showAlert = true
                    alertMessage = "다시 로그인 해주세요"
                    await networkManager.logout()
                }
            }
        }
    }
}
