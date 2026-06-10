import SwiftUI

struct NickNameChangeView: View {
    @EnvironmentObject var coordinator: Coordinator
    var store: SettingStore
    @FocusState var isFocused: Bool
    
    init(store: SettingStore) {
        self.store = store
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                NickNameField(name: nameBinding, isFocused: $isFocused, isValidName: isValidNameBinding)
                recordButton(condition: isValidNameBinding) {
                    store.send(.saveNickName)
                    coordinator.dismissSheet()
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
    
    private var nameBinding: Binding<String> {
        Binding(
            get: { store.state.name },
            set: { store.send(.updateName($0)) }
        )
    }
    
    private var isValidNameBinding: Binding<Bool> {
        Binding(
            get: { store.state.isValidName },
            set: { _ in }
        )
    }
    
    private func recordButton(condition: Binding<Bool>, task: @escaping() -> Void) -> some View {
        Button("변경하기") {
            guard condition.wrappedValue else { return }
            task()
        }.seedDaysButtonStyle(type: condition.wrappedValue ? .success : .normal, state: .primary)
    }
}
