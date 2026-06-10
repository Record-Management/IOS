import SwiftUI

/// UIWindow를 활용한 전체 화면 Overlay
/// Sheet를 포함한 모든 뷰 위에 표시됩니다.
///
/// 사용법:
/// ```swift
/// .windowOverlay(isPresented: $isOverlay) {
///     Rectangle()
///         .fill(.black.opacity(0.4))
///         .ignoresSafeArea()
///         .onTapGesture { isOverlay = false }
/// }
/// ```
struct WindowOverlay<OverlayContent: View>: UIViewRepresentable {
    @Binding var isPresented: Bool
    @ViewBuilder var overlayContent: () -> OverlayContent
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 현재 UIWindowScene 가져오기
        guard let windowScene = uiView.window?.windowScene else { return }
        
        if isPresented {
            // 이미 표시 중이면 무시
            if context.coordinator.overlayWindow != nil { return }
            
            let window = UIWindow(windowScene: windowScene)
            window.windowLevel = .alert + 1
            window.backgroundColor = .clear
            window.isUserInteractionEnabled = true
            
            let hostingController = UIHostingController(rootView: overlayContent())
            hostingController.view.backgroundColor = .clear
            window.rootViewController = hostingController
            window.makeKeyAndVisible()
            
            context.coordinator.overlayWindow = window
        } else {
            context.coordinator.overlayWindow?.isHidden = true
            context.coordinator.overlayWindow = nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var overlayWindow: UIWindow?
    }
}

// MARK: - View Extension

extension View {
    /// Sheet를 포함한 모든 뷰 위에 overlay를 표시합니다.
    /// UIWindow를 활용하여 별도의 레이어에 표시됩니다.
    func windowOverlay<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay(
            WindowOverlay(
                isPresented: isPresented,
                overlayContent: content
            )
        )
    }
}
