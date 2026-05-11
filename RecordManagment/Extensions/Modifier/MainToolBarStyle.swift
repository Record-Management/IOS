import SwiftUI

/// 메인 화면의 툴바 스타일을 정의하는 ViewModifier입니다.
/// 시트의 상태(medium, large)에 따라 상단 툴바 아이템(D-Day, 뒤로가기, 알림, 설정 등)의 배치를 자동으로 조정합니다.
fileprivate struct MainToolBarStyle: ViewModifier {
    @EnvironmentObject private var coordinator: Coordinator
    @ObservedObject var mainVM: MainViewModel
    @ObservedObject var sheetVM: MainSheetViewModel
    /// 툴바를 표시할지 여부를 결정하는 조건입니다.
    let condition: Bool
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                if condition {
                    switch sheetVM.sheetState {
                    case .medium:
                        if DropDownFilter.matchingType(type: mainVM.user.data?.mainRecordType ?? "") != .all {
                            ToolbarItem(placement: .topBarLeading) {
                                HStack(spacing: 4) {
                                    Image(DropDownFilter.matchingType(type: mainVM.user.data?.mainRecordType ?? "").getImage())
                                    if let goalDay = mainVM.user.data?.goalDays {
                                        Text("D-\(goalDay)")
                                            .typography(.p16SemiBold)
                                    }
                                }
                                .onTapGesture {
                                    mainVM.isGoalReset = true
                                }
                            }
                        }
                    case .large:
                        ToolbarItem(placement: .topBarLeading) {
                            Image(systemName: "chevron.left")
                                .higBackSize()
                                .onTapGesture {
                                    withAnimation(.interactiveSpring) {
                                        sheetVM.sheetState = .medium
                                    }
                                }
                        }
                        if DropDownFilter.matchingType(type: mainVM.user.data?.mainRecordType ?? "") != .all {
                            ToolbarItem(placement: .title) {
                                HStack(spacing: 4) {
                                    Image(DropDownFilter.matchingType(type: mainVM.user.data?.mainRecordType ?? "").getImage())
                                    if let goalDay = mainVM.user.data?.goalDays {
                                        Text("D-\(goalDay)")
                                            .typography(.p16SemiBold)
                                    }
                                }
                                .onTapGesture {
                                    mainVM.isGoalReset = true
                                }
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Image("Notification")
                            .higTouchArea()
                            .onTapGesture {
                                coordinator.push(.notification)
                            }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Image("Setting")
                            .higTouchArea()
                            .onTapGesture {
                                coordinator.push(.setting)
                            }
                    }
                }
            }
    }
}

// View Extension

extension View {
    /// SeedDay 전용  메인 툴바를 적용합니다
    /// - Parameters:
    ///   - condition: 툴바 노출 여부
    /// - Returns: 메인 화면에  적용된 toolbar
    func seedDayMainToolBar(
        @ObservedObject mainVM: MainViewModel,
        @ObservedObject sheetVM: MainSheetViewModel,
        condition: Bool
    ) -> some View {
        self.modifier(
            MainToolBarStyle(
                mainVM: mainVM,
                sheetVM: sheetVM,
                condition: condition
            )
        )
    }
}
