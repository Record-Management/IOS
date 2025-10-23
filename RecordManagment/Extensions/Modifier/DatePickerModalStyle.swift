import SwiftUI

struct DatePickerModalStyle: ViewModifier {
    @Binding var isShow: Bool
    @Binding var selection: Date
    let title: String
    let cancel: () -> Void
    let update: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isShow {
                    DatePickerAlertView(
                        selection: $selection,
                        title: title,
                        cancel: cancel,
                        update: update
                    )
                }
            }
    }
}

extension View {
    func showDatePickerModal(isShow: Binding<Bool> ,selection: Binding<Date>, title: String, cancel: @escaping () -> Void, update: @escaping () -> Void) -> some View {
        self
            .modifier(DatePickerModalStyle(isShow: isShow, selection: selection, title: title, cancel: cancel, update: update))
    }
}
