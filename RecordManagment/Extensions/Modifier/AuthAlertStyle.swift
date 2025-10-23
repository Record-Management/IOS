import SwiftUI

struct AuthAlertStyle: ViewModifier {
    @Binding var isAlert: Bool
    let method: AuthBox.Escape
    let cancel: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isAlert {
                    AuthBox(method: method, cancel: cancel)
                }
            }
    }
}

extension View {
    func showAuthAlertView(isAlert: Binding<Bool>, method: AuthBox.Escape, cancel: @escaping() -> Void) -> some View {
        self
            .modifier(AuthAlertStyle(isAlert: isAlert, method: method, cancel: cancel))
    }
}
