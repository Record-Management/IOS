import SwiftUI

struct FloatingButton<Label: View>: View {
    // action
    var buttonSize: CGFloat
    var actions: [FloatingActionMenuItem]
    @Binding var isExtends: Bool
    var label: (Bool) -> Label
    
    init(
        buttonSize: CGFloat = 50,
        isExtends: Binding<Bool>,
        @FloatingActionMenuBuilder actions: @escaping() -> [FloatingActionMenuItem],
        label: @escaping (Bool) -> Label
    ) {
        self.buttonSize = buttonSize
        self._isExtends = isExtends
        self.actions = actions()
        self.label = label
    }
    
    var body: some View {
        Button() {
            isExtends.toggle()
        } label: {
            label(isExtends)
                .frame(width: buttonSize, height: buttonSize)
                .contentShape(.rect)
        }
        .buttonStyle(AnimationFloatingButtonStyle())
        .background(alignment: .bottom) {
            if isExtends {
                let width = UIScreen.main.bounds.width * Constant.Floating.menuWidthRatio
                VStack(spacing: 0) {
                    ForEach(actions) { menu in
                        menuItem(menu, disabled: menu.disabled)
                    }
                }
                .frame(width: width)
                .background(.white, in: RoundedRectangle(cornerRadius: Constant.Floating.cornerRadius))
                .shadow(color: .black.opacity(Constant.Floating.shadowOpacity), radius: Constant.Floating.shadowRadius, x: 0, y: Constant.Floating.shadowY)
                .offset(x: -width / 2 + buttonSize / 2, y: -buttonSize - Constant.Floating.menuSpacing)
                .transition(.scale(scale: Constant.Floating.transitionScale, anchor: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: Constant.Floating.animationDuration, extraBounce: 0), value: isExtends)
    }
    
    @ViewBuilder
    private func menuItem(_ menu: FloatingActionMenuItem, disabled: Bool = false) -> some View {
        Button {
            menu.action()
            isExtends = false
        } label: {
            HStack(spacing: Constant.Floating.itemSpacing) {
                Image(menu.seedType.getImage())
                    .font(.body)
                    .foregroundStyle(Color.Primary.main())
                Text(menu.seedType.getTitle())
                    .typography(.p16Medium)
                    .foregroundStyle(Color.Gray._800())
                Spacer()
            }
            .padding(.horizontal, Constant.Floating.itemHorizontalPadding)
            .padding(.vertical, Constant.Floating.itemVerticalPadding)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.Gray._900())
        .disabled(disabled)
    }
}

// MARK: Button Style
struct AnimationFloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}


// MARK: - Action 아이템 모델

struct FloatingActionMenuItem: Identifiable {
    private(set) var id: UUID = .init()
    var seedType: SeedType
    var disabled: Bool = false
    var font: Font = .title3
    var tint: Color = Color.Gray._900()
    var background: Color = .white
    var action: () -> ()
}


@resultBuilder
struct FloatingActionMenuBuilder {
    static func buildBlock(_ components: FloatingActionMenuItem...) -> [FloatingActionMenuItem] {
        components.compactMap({ $0 })
    }
}

#Preview {
    
}
