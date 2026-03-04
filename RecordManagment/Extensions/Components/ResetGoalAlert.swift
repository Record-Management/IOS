import SwiftUI


struct ResetGoalAlert: View {
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
                Text("설정된 목표를 초기화 하시겠습니까?")
                    .typography(.p16SemiBold)
                    .padding(.bottom,8)
                Text("기존 설정된 목표를 초기화합니다.\n초기화 후에는 새로운 목표를 설정해주세요.")
                    .typography(.p14Regular)
                    .foregroundStyle(Color.Gray._600())
                    .padding(.bottom, 16)
                    .multilineTextAlignment(.center)
                HStack {
                    alertBox("닫기", bgColor: Color.Gray._100(), textColor: Color.Gray._400(), action: cancel)
                    alertBox("초기화", bgColor: Color.Primary.main(), textColor: .white) {
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
