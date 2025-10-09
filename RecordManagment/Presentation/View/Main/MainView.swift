import SwiftUI

struct MainView: View {
    @StateObject var selectionVM: RecordSelectionView.ViewModel = .init(
        useCase: UserUseCase(
            repository: DefaultUserRepository()
        )
    )
    @StateObject private var recordVM: RecordViewModel = .init(
        useCase: RecordUseCase(
            repository: DefaultRecordRepository()
        )
    )
    @EnvironmentObject var rm: RouterView.ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @State private var offset: CGFloat = 0
    @State private var topDetent: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. Background Image
            Image("Main")
                .resizable()
                .ignoresSafeArea()
                .opacity(sheetVM.sheetState == .medium ? 1 : 0)
                .animation(.easeInOut, value: sheetVM.sheetState)
            
            MainSheet(
                offset: offset,
                topDetent: topDetent,
                recordVM: recordVM
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
                coordinator.present(.recordSelection(
                    selectionVM: selectionVM,
                    selectedDate: $recordVM.selectedDate
                ))
            }
            .frame(width: 52, height: 52)
            .padding(.trailing, 16)
            .padding(.bottom, 52 + 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .zIndex(1)
        )
        .ignoresSafeArea(edges: [.top])
        .toolbar {
            if sheetVM.sheetState == .large {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                        .higBackSize()
                        .onTapGesture {
                            withAnimation(.interactiveSpring) {
                                sheetVM.sheetState = .medium
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
        .task {
            selectionVM.currentRecord = await selectionVM.getCurrentRecordType()
            selectionVM.originalRecord = selectionVM.currentRecord // 저장
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
