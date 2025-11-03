import SwiftUI

struct HabitRecordMainAlertStyle: ViewModifier {
    @Binding var isAlert: Bool
    let action: () -> Void
    @State private var internalVisible = true

    func body(content: Content) -> some View {
            content
                .overlay {
                    if isAlert && internalVisible {
                        ChangeMainHabitRecord(
                            cancel: {
                            isAlert = false
                            internalVisible = false
                        }, action: {
                            internalVisible = false
                        })
                    }
                }
                .onChange(of: isAlert) {
                    if isAlert { internalVisible = true }
                }
        }
}

extension View {
    func showMainRecordAlertView(isAlert: Binding<Bool>, action: @escaping() -> Void) -> some View {
        self
            .modifier(HabitRecordMainAlertStyle(isAlert: isAlert, action: action))
    }
}
