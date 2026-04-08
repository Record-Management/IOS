import SwiftUI

struct ContentView: View {
    @AppStorage("SeeTheAdministrationPage") private var isPage: Bool = false
    @StateObject var coordinator = Coordinator()
    @StateObject var rm: RouterView.ViewModel = .init(
        useCase: DefaultRouterUseCase(
            repository: DefaultRouterRepository()
        )
    )
    
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: isPage ? .root : .admin) // default: Login and isPage에 따른 권한 페이지 보여주기
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    coordinator.build(sheet: sheet)
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
                    coordinator.build(fullScreenCover: cover)
                }
                .toolbarBackground(.hidden, for: .navigationBar)
        }
        .environmentObject(coordinator)
        .environmentObject(rm)
        .alert(rm.alertMessage, isPresented: $rm.showAlert) {
            Button("확인", role: .cancel) { }
        }
        .onAppear {
            clearBackground()
        }
    }
}

#Preview {
    ContentView()
}
