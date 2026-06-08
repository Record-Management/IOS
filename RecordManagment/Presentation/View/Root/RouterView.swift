import SwiftUI

struct RouterView: View {
    @EnvironmentObject var coordinator: Coordinator
    private let store: RouterStore
    
    init(store: RouterStore) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            switch store.authStore.state {
                case .initialize:
                    SplashScreen() // splashScreen
                        .transition(.opacity)
                case .login:
                    coordinator.build(page: .login)
                        .transition(.opacity)
                case .register:
                    coordinator.build(page: .term) // term -> section -> main
                        .transition(.opacity)
                case .main:
                    coordinator.build(page: .main)
                        .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.authStore.state)
        .onAppear { store.send(.onAppearPreload) }
    }
}
