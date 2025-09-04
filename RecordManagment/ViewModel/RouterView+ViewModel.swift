import Foundation

extension RouterView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var currentState: UserState = .initialize
        let networkManager = LoginNetworkManager()
        
        func autoLogin() async {
            self.currentState = await networkManager.autoLogin()
        }
    }
}
