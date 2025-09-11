import SwiftUI

struct MainView: View {
    @EnvironmentObject var rm: RouterView.ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @State private var sheet: Bool = true
    @State private var fullScreenCover: Bool = false
    @State private var navigationBarHeight: CGFloat = 0
    @State private var currentDetent: PresentationDetent = .height(UIScreen.main.bounds.height * 0.6)
    let medium = UIScreen.main.bounds.height * 0.6
    var loginManager: LoginNetworkManager = .init()
    
    var body: some View {
        ZStack(alignment: .top){
            Image("Main")
                .resizable()
                .ignoresSafeArea()
                .opacity(currentDetent == .height(medium) ? 1 : 0)
                .animation(.easeInOut, value: currentDetent)
        }
        .sheet(isPresented: $sheet) {
            ScrollView {
                CalenderView()
            }
            .presentationDetents([
                .height(medium),
                .fraction((UIScreen.main.bounds.height - navigationBarHeight) / UIScreen.main.bounds.height)
            ], selection: $currentDetent)
            .presentationBackgroundInteraction(.enabled)
            .interactiveDismissDisabled()
            .background {
                GeometryReader { geo in
                    Color.clear.onAppear {
                        self.navigationBarHeight = geo.safeAreaInsets.top + 44
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Image("Notification")
                    Image("Setting")
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle("메인 화면")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // TODO: Test Box
    private func testBox() -> some View {
            Group {
                Button("로그 아웃") {
                    Task {
                        await loginManager.logout()
                        rm.currentState = .login
                        coordinator.popToRoot()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("회원 탈퇴") {
                    Task {
                        await loginManager.WithdrawMembership()
                        rm.currentState = .login
                        coordinator.popToRoot()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
}

#Preview {
    NavigationStack {
        MainView()
    }
}
