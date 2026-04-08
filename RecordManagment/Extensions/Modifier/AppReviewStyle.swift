import SwiftUI

struct AppReviewStyle: ViewModifier {
    @Binding var isShow: Bool
    let cancel: () -> Void
    let action: () -> Void
    
    init(isShow: Binding<Bool>, cancel: @escaping () -> Void, action: @escaping () -> Void) {
        self._isShow = isShow
        self.cancel = cancel
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isShow {
                    AppReviewAlert(cancel: cancel, action: action)
                }
            }
    }
}

extension View {
    
    @ViewBuilder
    func showAppReviewAlert(
        isShow: Binding<Bool>,
        cancel: @escaping () -> Void,
        action: @escaping () -> Void
    ) -> some View {
        self.modifier(
            AppReviewStyle(
                isShow: isShow,
                cancel: cancel,
                action: action,
            )
        )
    }
}

