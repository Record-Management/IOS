import SwiftUI

struct RouterView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var rm: RouterView.ViewModel
    
    var body: some View {
        Group {
            switch rm.currentState {
                case .initialize:
                    SplashScreen() // splashScreen
                case .login:
                    coordinator.build(page: .login)
                case .register:
                    coordinator.build(page: .term) // term -> section -> main
                case .main:
                    coordinator.build(page: .main)
            }
        }
        .onAppear {
            Task {
                await rm.autoLogin()
            }
        }
    }
}
