//
//  EmotionSelectionView .swift
//  RecordManagment
//
//  Created by 김용해 on 9/12/25.
//

import SwiftUI

struct RecordSelectionView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                switch vm.currentRecord {
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
                    case .schedule:
                        EmptyView()
                    case .habit:
                        EmptyView()
                }
                Spacer()
                Text("기록 방식을 바꿀래요")
                    .typography(.p14Medium)
                    .underline()
                    .foregroundStyle(Color.Gray._600())
                    .onTapGesture {
                        vm.isAlert = true
                    }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image("xmark")
                        .frame(maxWidth: 24, maxHeight: 24)
                        .higFullScreenBackSize()
                        .onTapGesture {
                            coordinator.dismissScreen()
                            vm.isAlert = false
                            vm.currentRecord = vm.originalRecord
                        }
                }
            }
            .overlay {
                if vm.isAlert {
                    ChangeRecordAlertView(
                        isAlert: $vm.isAlert,
                        currentRecord: $vm.currentRecord,
                        selectedRecord: $vm.selectedRecord
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RecordSelectionView()
        .environmentObject(Coordinator())
}
