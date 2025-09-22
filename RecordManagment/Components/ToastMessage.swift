import SwiftUI

struct ToastMessage: View {
    @Binding var visibleToast: Bool
    var toastMessage: String?
    
    var body: some View {
        if let toastMessage = toastMessage,
            visibleToast {
            VStack {
                Spacer()
                Text(toastMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Color.Gray._600())
                    .clipShape(.rect(cornerRadius: 8))
                Spacer().frame(maxHeight: 86)
            }
        }
    }
}
