import SwiftUI

// MARK: Helper for specific corner radius 함수
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

// MARK: View ContentShape min Size 44pt HIG 적용
extension View {
    func higBackSize() -> some View {
        self
            .padding([.bottom, .trailing, .top])
            .contentShape(Rectangle())
    }
    
    // FullScreenCover dismiss Button
    func higFullScreenBackSize() -> some View {
        self
            .padding([.top, .bottom, .leading])
            .contentShape(Rectangle())
    }
}

// MARK: NavigationBar Background 제거
extension View {
    func clearBackground(_ color: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = color
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

// MARK: ToolBar ViewModifier 적용된 함수
extension View {
    @ViewBuilder
    func seeDayToolBar(_ visible: Bool? = nil, _ action: @escaping () -> Void) -> some View {
        self.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                let button = Button(action: {
                    action()
                }) {
                    Image(systemName: "chevron.left")
                        .higBackSize()
                        .foregroundStyle(Color.Gray._900())
                }
                
                if let visible {
                    button.modifier(SectionOneToolBarStyle(visible: visible))
                } else {
                    button
                }
            }
        }
    }
}
