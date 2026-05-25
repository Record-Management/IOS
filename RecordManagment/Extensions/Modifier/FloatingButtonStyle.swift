import SwiftUI

/// 특정 조건에 따라 화면에 플로팅 버튼을 추가하는 ViewModifier입니다.
/// 확장 시 dim 배경으로 하위 콘텐츠의 터치를 차단하며, `isExtends` Binding을 통해 외부에서도 확장 상태를 관찰할 수 있습니다.
/// - Note: Navigation Bar는 UIKit 레이어에 존재하므로, toolbar 아이템의 터치 차단은 `isExtends`를 toolbar 쪽에서 직접 참조하여 처리해야 합니다.
struct FloatingButtonStyle: ViewModifier {
    /// 버튼을 표시할지 여부를 결정하는 조건입니다.
    let condition: Bool
    /// bottom Padding
    let bottomPadding: CGFloat
    /// 메인 기록 SeedType
    let mainSeedType: SeedType
    /// 기록 비활성화 여부 상태 값
    let disabled: Bool
    /// 일정 기록 Action
    let scheduleAction: () -> Void
    /// 하루, 운동, 습관 기록 Action
    let recordAction: () -> Void
    /// 플로팅 버튼 확장 상태 (외부에서 toolbar 등과 연동 가능)
    @Binding var isExtends: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isExtends {
                    Color.black.opacity(Constant.Floating.dimOpacity)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.snappy(duration: Constant.Floating.animationDuration)) {
                                isExtends = false
                            }
                        }
                        .transition(.opacity)
                }
            }
            .animation(.snappy(duration: Constant.Floating.animationDuration), value: isExtends)
            .overlay(alignment: .bottomTrailing) {
                if condition {
                    FloatingButton(
                        isExtends: $isExtends,
                        actions: {
                            FloatingActionMenuItem(seedType: .schedule) {
                                scheduleAction()
                            }
                            
                            FloatingActionMenuItem(seedType: mainSeedType, disabled: disabled) {
                                recordAction()
                            }
                        }
                    ) { isExtends in
                        Image(systemName: isExtends ? "xmark" : "pencil")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(isExtends ? .black : .white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(
                                isExtends ? .white : Color.Primary.main(),
                                in: .circle
                            )
                            .sensoryFeedback(.selection, trigger: isExtends)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, bottomPadding)
                }
            }
    }
}


// View Extension

extension View {
    /// 화면 하단 우측에 SeedDay 전용 플로팅 버튼을 추가합니다.
    /// - Parameters:
    ///   - condition: 버튼 노출 여부
    ///   - bottomPadding: 버튼 하단 여백
    ///   - mainSeedType: 메인 기록 타입 (일정 외 기록 버튼에 표시)
    ///   - disabled: 기록 버튼 비활성화 여부
    ///   - isExtends: 플로팅 버튼 확장 상태 Binding (toolbar 연동용)
    ///   - scheduleAction: 일정 기록 버튼 탭 시 동작
    ///   - recordAction: 기록 버튼 탭 시 동작
    /// - Returns: 플로팅 버튼이 적용된 View
    func seedDayFloatingButton(
        condition: Bool,
        bottomPadding: CGFloat,
        mainSeedType: SeedType,
        disabled: Bool,
        isExtends: Binding<Bool>,
        scheduleAction: @escaping() -> Void,
        recordAction: @escaping() -> Void
    ) -> some View {
        self.modifier(
            FloatingButtonStyle(
                condition: condition,
                bottomPadding: bottomPadding,
                mainSeedType: mainSeedType,
                disabled: disabled,
                scheduleAction: scheduleAction,
                recordAction: recordAction,
                isExtends: isExtends
            )
        )
    }
}

