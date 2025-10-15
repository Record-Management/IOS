import SwiftUI

struct RecordListStyle: ViewModifier {
    let name: String
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: 70)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.Gray._50())
            .clipShape(.rect(cornerRadius: 8))
            .overlay {
                Text(name)
                    .typography(.p16SemiBold)
            }
    }
}
