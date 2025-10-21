import SwiftUI

struct PageModifierStyle: ViewModifier {
    let title: String
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                        .higBackSize()
                        .onTapGesture {
                            action()
                        }
                }
            }
            .navigationBarBackButtonHidden()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    func seedsDayNavigationStyle(title: String, action: @escaping () -> Void) -> some View {
        self.modifier(PageModifierStyle(title: title, action: action))
    }
}
