import SwiftUI

struct SectionOneToolBarStyle: ViewModifier {
    let visible: Bool
    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
    }
}
