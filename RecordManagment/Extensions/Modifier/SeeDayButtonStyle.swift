import SwiftUI

// TODO: 상태값 2개를 통해 버튼 스타일 분류 ( type, state )
enum ButtonType {
    case normal
    case success
}

enum ButtonState {
    case primary
    case secondary
        
}

struct PrimaryButtonStyle: ButtonStyle {
    let type: ButtonType
    let state: ButtonState
    
    init(type: ButtonType, state: ButtonState) {
        self.type = type
        self.state = state
    }
    
    var backgroundColor: Color {
        switch (type, state) {
            case (.normal,.primary):
                Color.Primary.lighter()
            case (.normal, .secondary):
                    Color.Gray._100()
            case (.success, .primary):
                Color.Primary.main()
            case (.success, .secondary):
                Color.Gray._100()
        }
    }
    
    var foregroundColor: Color {
        switch (type, state) {
            case (.normal,.primary):
                Color.Primary.main().opacity(0.4)
            case (.normal, .secondary):
                Color.Gray._400()
            case (.success, .primary):
                .white
            case (.success, .secondary):
                Color.Gray._900()
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typography(.p16Medium)
            .frame(maxWidth: .infinity, maxHeight: 52)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(.rect(cornerRadius: 8))
            
    }
}

extension View {
    /// SeedDays 버튼 전용 스타일을 적용합니다.
        ///
        /// `ButtonType`과 `ButtonState` 조합에 따라
        /// 버튼의 background, foreground 등 시각적 스타일을 일관되게 관리합니다.
        ///
        /// - Parameters:
        ///   - type: 버튼의 역할을 정의하는 타입 값 (예: primary, secondary 등)
        ///   - state: 버튼의 현재 상태 값 (예: normal, disabled, pressed 등)
        ///
        /// - Returns: 지정된 SeedDays 버튼 스타일이 적용된 View
        ///
        /// ### Example
        /// ```swift
        /// Button("확인") {
        ///     submit()
        /// }
        /// .seedDaysButtonStyle(type: .primary, state: .normal)
        /// ```
    func seedDaysButtonStyle(type: ButtonType, state: ButtonState) -> some View {
        self
            .buttonStyle(PrimaryButtonStyle(type: type, state: state))
    }
}

fileprivate struct SeeDayButtonStyle: View {
    var body: some View {
        VStack {
            Button("Button") {
                print("hello")
            }
            .seedDaysButtonStyle(type: .normal, state: .primary)
            Button("Button") {
                print("hello")
            }
            .seedDaysButtonStyle(type: .normal, state: .secondary)
            Button("Button") {
                print("hello")
            }
            .seedDaysButtonStyle(type: .success, state: .primary)
            Button("Button") {
                print("hello")
            }
            .seedDaysButtonStyle(type: .success, state: .secondary)
        }
    }
}

#Preview {
    SeeDayButtonStyle()
        .padding()
}
