import SwiftUI

struct RecordSelectionView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var isAlert: Bool = false
    @State private var selectedRecord: SeedType = .none
    let userStore: UserStore
    
    init(userStore: UserStore) {
        self.userStore = userStore
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                switch userStore.state.currentRecord {
                    case .none, .schedule:
                        ProgressView()
                    case .daily:
                        Text("오늘의 감정을 선택해 주세요")
                            .typography(.p20SemiBold)
                        EmotionView(isFullScreen: true)
                    case .exercise:
                        ExerciseListView() { exercise in
                            let vm = coordinator.appContainer.makeExerciseRecordViewModel(exercise: exercise)
                            coordinator.present(.exerciseRecord(vm: vm))
                        }
                    case .habit:
                        HabitListView { habit in
                            let vm = coordinator.appContainer.makeHabitRecordViewModel(habit: habit)
                            coordinator.present(.habitRecord(vm: vm))
                        }
                }
                Spacer()
                Text("기록 방식을 바꿀래요")
                    .typography(.p14Medium)
                    .underline()
                    .foregroundStyle(Color.Gray._600())
                    .onTapGesture {
                        isAlert = true
                    }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image("xmark")
                        .frame(maxWidth: 24, maxHeight: 24)
                        .higFullScreenBackSize()
                        .onTapGesture {
                            coordinator.dismissScreen()
                            isAlert = false
                            userStore.send(.setCurrentRecord(userStore.state.originalRecord))
                        }
                }
            }
            .overlay {
                if isAlert {
                    ChangeRecordAlertView(
                        isAlert: $isAlert,
                        currentRecord: bindingCurrentRecord,
                        selectedRecord: $selectedRecord
                    )
                }
            }
//            .overlay {
//                ToastMessage(visibleToast: $sheetVM.visibleToast, toastMessage: sheetVM.toastMessage)
//            }
            .onDisappear {
                userStore.send(.setCurrentRecord(userStore.state.originalRecord))
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var bindingCurrentRecord: Binding<SeedType> {
        Binding(
            get: { userStore.state.currentRecord },
            set: { userStore.send(.setCurrentRecord($0)) }
        )
    }
}
