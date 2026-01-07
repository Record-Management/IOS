import SwiftUI

struct NickNameChangeView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @EnvironmentObject var settingVM: SettingView.ViewModel
    @FocusState var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                NickNameField(name: $settingVM.name, isFocused: $isFocused, isValidName: $settingVM.isValidName)
                recordButton(condition: $settingVM.isValidName) {
                    Task {
                        let success = await settingVM.updateNickName()
                        coordinator.dismissSheet()
                        // sheetVM toastMessage
                        sheetVM.visibleToast = success
                        sheetVM.toastMessage = "닉네임이 변경되었습니다."
                    }
                }
            }
            .navigationTitle("닉네임 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image("xmark")
                        .frame(maxWidth: 24, maxHeight: 24)
                        .higFullScreenBackSize()
                        .onTapGesture {
                            coordinator.dismissSheet()
                        }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
        }
        .presentationDetents([.height(UIScreen.main.bounds.height * 0.3)])
        .interactiveDismissDisabled()
    }
    
    private func recordButton(condition: Binding<Bool>, task: @escaping() -> Void) -> some View {
        Button("변경하기") {
            guard condition.wrappedValue else { return }
            task()
        }.seedDaysButtonStyle(type: condition.wrappedValue ? .success : .normal, state: .primary)
    }
}

#Preview {
    NickNameChangeView()
}
