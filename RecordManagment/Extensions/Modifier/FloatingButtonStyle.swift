import SwiftUI

/// 특정 조건에 따라 화면에 플로팅 버튼을 추가하는 ViewModifier입니다.
struct FloatingButtonStyle: ViewModifier {
    /// 버튼을 표시할지 여부를 결정하는 조건입니다.
    let condition: Bool
    /// 버튼을 탭했을 때 실행될 클로저입니다.
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if condition {
                        FloatingButton() {
                            action()
                        }
                        .frame(width: 52, height: 52)
                        .padding(.trailing, 16)
                        .padding(.bottom, 52 + 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .zIndex(1)
                    } else {
                        EmptyView()
                    }
                }
            )
    }
}


// View Extension

extension View {
    /// 화면 하단 우측에 SeedDay 전용 플로팅 버튼을 추가합니다.
    /// - Parameters:
    ///   - condition: 버튼 노출 여부
    ///   - action: 버튼 클릭 시 동작
    /// - Returns: 플로팅 버튼이 적용된 View
    func seedDayFloatingButton(
        condition: Bool,
        action: @escaping() -> Void
    ) -> some View {
        self.modifier(
            FloatingButtonStyle(
                condition: condition,
                action: action
            )
        )
    }
}

