import SwiftUI

struct PresentAlertView: View {
    let store: AlertStore
    
    init(store: AlertStore) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            if store.state.isPresented {
                // 뒷 배경 딤 처리
                backgroundColor
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                AlertView(
                    title: store.state.title,
                    subTitle: store.state.subTitle,
                    secondaryButtonStyle: .init(
                        title: store.state.cancelTitle,
                        bgColor: Color.Gray._100(),
                        fgColor: Color.Gray._400()
                    ),
                    primaryButtonStyle: .init(
                        title: store.state.confirmTitle,
                        bgColor: store.state.isConfirmDestructive ? Color.Error.main() : Color.Primary.main(),
                        fgColor: .white
                    ),
                    cancel: {
                        store.state.onCancel?()
                        store.send(.dismiss)
                    },
                    action: {
                        store.state.onConfirm?()
                        store.send(.dismiss)
                    }
                )
                .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.smooth(duration: 0.25), value: store.state.isPresented)
    }
    
    private var backgroundColor: Color {
        Color(hex: "#222222").opacity(0.5)
    }
}
