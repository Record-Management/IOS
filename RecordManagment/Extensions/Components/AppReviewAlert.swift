import SwiftUI


struct AppReviewAlert: View {
    @EnvironmentObject var coordinator: Coordinator
    
    let cancel: () -> Void
    let action: () -> Void
    
    init(cancel: @escaping() -> Void, action: @escaping() -> Void) {
        self.cancel = cancel
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#222222").opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                Text("리뷰를 남겨주세요!")
                    .typography(.p16SemiBold)
                    .padding(.bottom,8)
                Text("저희 앱이 조금이나마 도움이 되고 있나요?\n잠시만 시간을 내어 리뷰를 남겨주시면, 씨드데이에\n큰 도움이 됩니다. 감사합니다.")
                    .typography(.p14Regular)
                    .foregroundStyle(Color.Gray._600())
                    .padding(.bottom, 16)
                    .multilineTextAlignment(.center)
                HStack {
                    alertBox("나중에", bgColor: Color.Gray._100(), textColor: Color.Gray._400(), action: cancel)
                    alertBox("별점 주기", bgColor: Color.Primary.main(), textColor: .white) {
                        cancel()
                        Task {
                            action()
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.horizontal, 32)
        }
    }
    
    private func alertBox(
        _ text: String,
        bgColor: Color,
        textColor: Color,
        action: @escaping() -> Void
    ) -> some View {
        Text(text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(bgColor)
            .foregroundStyle(textColor)
            .clipShape(.rect(cornerRadius: 8))
            .onTapGesture {
                action()
            }
    }
}
