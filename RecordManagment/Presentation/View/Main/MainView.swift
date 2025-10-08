import SwiftUI

struct MainView: View {
    @EnvironmentObject var rm: RouterView.ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @State var sheetState: SheetState = .medium
    @State private var offset: CGFloat = 0
    @State private var topDetent: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. Background Image
            Image("Main")
                .resizable()
                .ignoresSafeArea()
                .opacity(sheetState == .medium ? 1 : 0)
                .animation(.easeInOut, value: sheetState)
            
            MainSheet(
                offset: offset,
                topDetent: topDetent,
                sheetState: $sheetState
            )
            .environmentObject(rm)
            .environmentObject(sheetVM)
            .background {
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                let topInset = window.safeAreaInsets.top
                                self.topDetent = topInset + 44
                            }
                            self.offset = (geo.size.height - topDetent) * 0.4
                        }
                }
            }
        }
        .overlay(
            FloatingButton() {
                coordinator.present(.recordSelection)
            }
            .frame(width: 52, height: 52)
            .padding(.trailing, 16)
            .padding(.bottom, 52 + 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .zIndex(1)
        )
        .ignoresSafeArea(edges: [.top])
        .toolbar {
            if sheetState == .large {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                        .higBackSize()
                        .onTapGesture {
                            withAnimation(.interactiveSpring) {
                                sheetState = .medium
                            }
                        }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Image("Notification")
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Image("Setting")
            }
        }
        .toolbarBackground(.clear, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MainView()
    }
}
