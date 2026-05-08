import SwiftUI

struct ContentView: View {
    @AppStorage("SeeTheAdministrationPage") private var isPage: Bool = false
    @EnvironmentObject var coordinator: Coordinator
    
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
        .onAppear {
            clearBackground()
        }
    }
}
