import SwiftUI

/// 메인 화면의 툴바 스타일을 정의하는 ViewModifier입니다.
/// 시트의 상태(medium, large)에 따라 상단 툴바 아이템(D-Day, 뒤로가기, 알림, 설정 등)의 배치를 자동으로 조정합니다.
fileprivate struct MainToolBarStyle: ViewModifier {
    @EnvironmentObject private var coordinator: Coordinator
    /// 툴바 활성화  조건 상태 값
    @Binding var isExtends: Bool
    @Binding var presentationDetent: PresentationDetent
    @Bindable var store: MainStore
    
    /// 시트가 최대 높이까지 올라갔는지 여부
    private var isSheetFullyExpanded: Bool {
        presentationDetent != .fraction(Constant.Main.presentationDetent)
    }
    
    func body(content: Content) -> some View {
        let currentMainType: DropDownFilter = DropDownFilter.matchingType(
            type: store.userStore.state.user?.mainRecordType ?? ""
        )
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(isSheetFullyExpanded ? .white : .clear, for: .navigationBar)
            .toolbarBackgroundVisibility(isSheetFullyExpanded ? .visible : .hidden, for: .navigationBar)
            .toolbar {
                switch presentationDetent {
                case .fraction(Constant.Main.presentationDetent):
                    if currentMainType != .all {
                        ToolbarItem(placement: .topBarLeading) {
                            HStack(spacing: 4) {
                                Image(currentMainType.getImage())
                                if let goalDay = store.userStore.state.user?.goalDays {
                                    Text("D-\(goalDay)")
                                        .typography(.p16SemiBold)
                                }
                            }
                            .onTapGesture {
                                store.send(.resetGoalButtonTapped)
                            }
                            .disabled(isExtends)
                        }
                    }
                default:
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "chevron.left")
                            .higBackSize()
                            .onTapGesture {
                                withAnimation(.interactiveSpring) {
                                    presentationDetent = .fraction(Constant.Main.presentationDetent)
                                }
                            }
                            .disabled(isExtends)
                    }
                    
                    if currentMainType != .all {
                        ToolbarItem(placement: .title) {
                            HStack(spacing: 4) {
                                Image(currentMainType.getImage())
                                if let goalDay = store.userStore.state.user?.goalDays {
                                    Text("D-\(goalDay)")
                                        .typography(.p16SemiBold)
                                }
                            }
                            .onTapGesture {
                                store.send(.resetGoalButtonTapped)
                            }
                            .disabled(isExtends)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Image("Notification")
                        .higTouchArea()
                        .onTapGesture {
                            coordinator.push(.notification)
                        }
                        .disabled(isExtends)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Image("Setting")
                        .higTouchArea()
                        .onTapGesture {
                            coordinator.push(.setting)
                        }
                        .disabled(isExtends)
                }
            }
    }
}

// View Extension

extension View {
    /// SeedDay 전용  메인 툴바를 적용합니다
    /// - Parameters:
    ///   - condition: 툴바 노출 여부
    ///   - isExtends: floating action에 따라 toolbar를 비활성화 합니다.
    /// - Returns: 메인 화면에  적용된 toolbar
    func seedDayMainToolBar(
        isExtends: Binding<Bool>,
        presentationDetent: Binding<PresentationDetent>,
        store: MainStore
    ) -> some View {
        self.modifier(
            MainToolBarStyle(
                isExtends: isExtends,
                presentationDetent: presentationDetent,
                store: store
            )
        )
    }
}
