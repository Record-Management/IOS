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
    
    // common hig Area
    func higTouchArea(_ minSize: CGSize = CGSize(width: 44, height: 44)) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .frame(
                        width: max(minSize.width, geo.size.width),
                        height: max(minSize.height, geo.size.height)
                    )
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .allowsHitTesting(false)
        )
        .contentShape(Rectangle())
    }
}

// MARK: NavigationBar Background
extension View {
    func clearBackground() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.backgroundEffect = nil
        
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


// MARK: Record List Style
extension View {
    func exerciseListStyle(name: String) -> some View {
        self
            .modifier(RecordListStyle(name: name))
    }
    
    func habitListStyle(name: String) -> some View {
        self
            .modifier(RecordListStyle(name: name))
    }
}


// MARK: 목표기간이 없는 경우
extension View {
    func noGoalPeriodView(
        condition: Bool,
        checkGoal: Bool,
        complete: @escaping() -> Void
    ) -> some View {
        let isCardVisible = !checkGoal && condition
        return self.overlay(
            Group {
                if isCardVisible {
                    SeeDayBottomCard(
                        title: "새로운 목표를 통해\n또 다른 하루를 시작해요",
                        cardTitle: "새 목표 설정하기"
                    ) {
                        complete()
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    NotificationCenter.default.post(
                                        name: .noGoalCardFrameChanged,
                                        object: geometry.frame(in: .global)
                                    )
                                }
                                .onChange(of: geometry.frame(in: .global)) { oldFrame, newFrame in
                                    NotificationCenter.default.post(
                                        name: .noGoalCardFrameChanged,
                                        object: newFrame
                                    )
                                }
                        }
                    )
                    .padding(.horizontal)
                    .zIndex(2)
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }
            }
            .onAppear {
                NotificationCenter.default.post(
                    name: .checkGoalChanged,
                    object: isCardVisible
                )
            }
            .onChange(of: isCardVisible) { oldValue, newValue in
                NotificationCenter.default.post(
                    name: .checkGoalChanged,
                    object: newValue
                )
            },
            alignment: .bottom
        )
    }
}

// MARK: - 기본 Transaction 지우기

extension View {
    func withoutAnimation(block: @escaping() -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            defer {
                Task { @MainActor in
                    UIView.setAnimationsEnabled(true)
                }
            }
            do {
                UIView.setAnimationsEnabled(false)
                block()
            }
        }
    }
}
