import SwiftUI

// MARK: - Draggable Panel View
struct MainSheet: View {
    var offset: CGFloat
    var topDetent: CGFloat
    @Binding var sheetState: SheetState
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var rm: RouterView.ViewModel
    @EnvironmentObject private var vm: MainSheetViewModel
    var loginManager: LoginNetworkManager = .init()
    
    init(offset: CGFloat, topDetent: CGFloat, sheetState: Binding<SheetState>) {
        self.offset = offset
        self.topDetent = topDetent
        self._sheetState = sheetState
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle to indicate draggability
            Capsule()
                .fill(Color.secondary)
                .frame(width: 40, height: 5)
                .padding(.vertical, 10)

            ScrollView {
                CalenderView()
                Button("logout") {
                    Task {
                        await loginManager.logout()
                        await MainActor.run {
                            rm.currentState = .login
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("회원 탈퇴") {
                    Task {
                        await loginManager.WithdrawMembership()
                        await MainActor.run {
                            rm.currentState = .login
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color(.systemBackground))
        .frame(height: UIScreen.main.bounds.height)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .offset(y: sheetState == .medium ? offset : topDetent)
        .animation(.spring(duration: 0.25), value: sheetState)
        .simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    let move = value.translation.height
                    if move > 100 {
                        SheetState.down(&sheetState)
                    } else if move < -100 {
                        SheetState.up(&sheetState)
                    }
                }
        )
        .overlay {
            ToastMessage(visibleToast: $vm.visibleToast, toastMessage: vm.toastMessage)
        }
    }
}

enum SheetState {
    case medium
    case large
    
    static func up(_ state: inout SheetState) {
        switch state {
            case .large:
                return
            case .medium:
                state = .large
        }
    }
    
    static func down(_ state: inout SheetState) {
        switch state {
            case .large:
                state = .medium
            case .medium:
                return
        }
    }
}
