import SwiftUI

struct BasicSeeDayButton: View {
    @Binding var isOpen: Bool
    let onClick: () -> Void
    
    var body: some View {
        Text("확인")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(isOpen ? .white : Color.Primary.light())
            .background(isOpen ? Color.Primary.main() : Color.Primary.lighter())
            .animation(.easeInOut, value: isOpen)
            .clipShape(.rect(cornerRadius: 8))
            .onTapGesture {
                onClick()
            }
    }
}

#Preview {
    BasicSeeDayButton(isOpen: .constant(false), onClick: {})
}
