import SwiftUI

// MARK: - Draggable Panel View
struct MainSheet: View {
    var offset: CGFloat
    var topDetent: CGFloat
    @Binding var sheetState: SheetState
    @EnvironmentObject var coordinator: Coordinator
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
                        let result = await loginManager.logout()
                        coordinator.popToRoot()
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("회원 탈퇴") {
                    Task {
                        await loginManager.WithdrawMembership()
                        coordinator.popToRoot()
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
        .gesture(
            DragGesture()
                .onChanged { value in
                    let move = value.translation.height
                    if move > 0 {
                        SheetState.down(&sheetState)
                    } else {
                        SheetState.up(&sheetState)
                    }
                }
        )
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
