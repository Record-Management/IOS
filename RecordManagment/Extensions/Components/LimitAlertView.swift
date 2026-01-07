import SwiftUI

struct LimitAlertView: View {
    let error: RecordError
    let action: () -> Void
    var body: some View {
        ZStack {
            Color(hex: "#222222").opacity(0.2).ignoresSafeArea()
            VStack {
                Text(error.getTitle())
                    .typography(.p16SemiBold)
                    .padding(.bottom,8)
                    .foregroundStyle(Color.Gray._900())
                Text(error.getSubTitle())
                    .typography(.p14Regular)
                    .padding(.bottom, 16)
                    .foregroundStyle(Color.Gray._600())
                Button("확인") {
                    action()
                }
                .seedDaysButtonStyle(type: .success, state: .primary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.horizontal, 32)
        }
    }
}
