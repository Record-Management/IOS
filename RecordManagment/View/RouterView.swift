import SwiftUI

struct RouterView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var rm: RouterView.ViewModel
    var body: some View {
        Group {
            switch rm.currentState {
                case .initialize:
                    ProgressView()
                case .login:
                    coordinator.build(page: .login)
                case .register:
                    coordinator.build(page: .section)
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
