import SwiftUI

struct RecordSelectionView: View {
    @EnvironmentObject var coordinator: Coordinator
    @ObservedObject var mainVM: MainViewModel
    @ObservedObject var sheetVM: MainSheetViewModel
    
    init(mainVM: MainViewModel, sheetVM: MainSheetViewModel) {
        self.mainVM = mainVM
        self.sheetVM = sheetVM
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                switch mainVM.currentRecord {
                    case .none:
                        ProgressView()
                    case .daily:
                        Text("오늘의 감정을 선택해 주세요")
                            .typography(.p20SemiBold)
                        EmotionView(isFullScreen: true)
                    case .exercise:
                        ExerciseListView() { exercise in
                            coordinator.present(.exerciseRecord(exercise: exercise))
                        }
                    case .habit:
                        HabitListView { habit in
                            coordinator.present(.habitRecord(habit: habit))
                        }
                }
                Spacer()
                Text("기록 방식을 바꿀래요")
                    .typography(.p14Medium)
                    .underline()
                    .foregroundStyle(Color.Gray._600())
                    .onTapGesture {
                        mainVM.isAlert = true
                    }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image("xmark")
                        .frame(maxWidth: 24, maxHeight: 24)
                        .higFullScreenBackSize()
                        .onTapGesture {
                            coordinator.dismissScreen()
                            mainVM.isAlert = false
                            mainVM.currentRecord = mainVM.originalRecord
                        }
                }
            }
            .overlay {
                if mainVM.isAlert {
                    ChangeRecordAlertView(
                        isAlert: $mainVM.isAlert,
                        currentRecord: $mainVM.currentRecord,
                        selectedRecord: $mainVM.selectedRecord
                    )
                }
            }
            .overlay {
                ToastMessage(visibleToast: $sheetVM.visibleToast, toastMessage: sheetVM.toastMessage)
            }
            .onDisappear {
                mainVM.currentRecord = mainVM.originalRecord
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
