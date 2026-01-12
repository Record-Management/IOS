import SwiftUI

struct DismissAlertView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Binding var isDismiss: Bool
    @Binding var method: RecordMethod
    let deleteAction: (() -> Void)?
    let state: Record
    
    init(isDismiss: Binding<Bool>, method: Binding<RecordMethod>, state: Record, deleteAction: (() -> Void)? = nil) {
        self._isDismiss = isDismiss
        self._method = method
        self.state = state
        self.deleteAction = deleteAction
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#222222").opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                Text(method.getTitle())
                    .typography(.p16SemiBold)
                    .padding(.bottom,8)
                Text(method.getSubTitle())
                    .typography(.p14Regular)
                    .padding(.bottom, 16)
                HStack(spacing: 10) {
                    alertBox(method.alertButtonText().left, bgColor: Color.Gray._100(), textColor: Color.Gray._400()) {
                        isDismiss = false
                        switch method {
                            case .create:
                                // logging Insert
                                switch state {
                                    case .none:
                                        return
                                    case .daily:
                                        AnalyticsManager.shared.logDailyCancel()
                                    case .exercise:
                                        AnalyticsManager.shared.logExerciseCancel()
                                    case .habit:
                                        AnalyticsManager.shared.logHabitCancel()
                                }
                                coordinator.dismissScreen()
                            case .update:
                                coordinator.pop()
                            case .delete:
                                method = .update
                                return
                        }
                    }
                    alertBox(method.alertButtonText().right, bgColor: Color.Primary.main(), textColor: .white) {
                        isDismiss = false
                        switch method {
                            case .create, .update:
                                return
                            case .delete:
                                debugPrint("삭제하기 기능")
                                deleteAction?()
                                return
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 52)
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
}

private extension DismissAlertView {
    func alertBox(
        _ text: String,
        bgColor: Color,
        textColor: Color,
        action: @escaping() -> Void
    ) -> some View {
        Text(text)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgColor)
            .foregroundStyle(textColor)
            .clipShape(.rect(cornerRadius: 8))
            .onTapGesture {
                action()
            }
    }
}
