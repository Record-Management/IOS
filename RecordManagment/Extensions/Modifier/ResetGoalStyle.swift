import SwiftUI

struct ResetGoalAlertStyle: ViewModifier {
    @Binding var isGoalReset: Bool
    let cancel: () -> Void
    let action: () -> Void
    
    init(isGoalReset: Binding<Bool>, cancel: @escaping () -> Void, action: @escaping () -> Void) {
        self._isGoalReset = isGoalReset
        self.cancel = cancel
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isGoalReset {
                    ResetGoalAlert(cancel: cancel, action: action)
                }
            }
    }
}

extension View {
    
    @ViewBuilder
    func showResetGoalAlert(
        isGoalReset: Binding<Bool>,
        cancel: @escaping () -> Void,
        action: @escaping () -> Void
    ) -> some View {
        self.modifier(
            ResetGoalAlertStyle(
                isGoalReset: isGoalReset,
                cancel: cancel,
                action: action,
            )
        )
    }
}

