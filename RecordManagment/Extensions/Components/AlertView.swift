import SwiftUI


struct AlertView: View {
    @EnvironmentObject var coordinator: Coordinator
    
    let title: String
    let subTitle: String
    let secondaryButtonStyle: ButtonType
    let primaryButtonStyle: ButtonType
    let cancel: () -> Void
    let action: () -> Void
    
    init(
        title: String,
        subTitle: String,
        secondaryButtonStyle: ButtonType,
        primaryButtonStyle: ButtonType,
        cancel: @escaping() -> Void,
        action: @escaping() -> Void
    ) {
        self.title = title
        self.subTitle = subTitle
        self.secondaryButtonStyle = secondaryButtonStyle
        self.primaryButtonStyle = primaryButtonStyle
        self.cancel = cancel
        self.action = action
    }
    
    var body: some View {
        
        VStack {
            Text(title)
                .typography(.p16SemiBold)
                .padding(.bottom,8)
            Text(subTitle)
                .typography(.p14Regular)
                .foregroundStyle(Color.Gray._600())
                .padding(.bottom, 16)
                .multilineTextAlignment(.center)
            HStack {
                alertBox(
                    secondaryButtonStyle.title,
                    bgColor: secondaryButtonStyle.bgColor,
                    textColor: secondaryButtonStyle.fgColor,
                    action: cancel
                )
                alertBox(
                    primaryButtonStyle.title,
                    bgColor: primaryButtonStyle.bgColor,
                    textColor: primaryButtonStyle.fgColor
                ) {
                    cancel()
                    action()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .padding(.horizontal, 32)
        
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
    
    struct ButtonType {
        let title: String
        let bgColor: Color
        let fgColor: Color
    }
}
