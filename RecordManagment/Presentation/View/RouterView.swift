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
                coordinator.selectionVM.currentRecord = await coordinator.selectionVM.getCurrentRecordType()
                coordinator.selectionVM.originalRecord = coordinator.selectionVM.currentRecord // 저장
            }
        }
    }
}
