import SwiftUI

struct HabitRecordCard: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var recordVM: RecordViewModel
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @State private var pressGesture: Bool = false
    @Binding var isDismiss: Bool
    @State private var isCompleted: Bool = false
    
    let info: HabitResponse
    let completeAction: (String ,Bool) -> Void
    
    init(info: HabitResponse, isDismiss: Binding<Bool>, completeAction: @escaping (String, Bool) -> Void) {
        self.info = info
        self._isDismiss = isDismiss
        self.completeAction = completeAction
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .center) {
                Circle()
                    .fill(.white)
                Image(info.habitType)
                    .resizable()
                    .scaledToFit().frame(maxWidth: 50, maxHeight: 50)
            }
            .frame(maxWidth: 66, maxHeight: 66)
            .habitMainPin(isMainRecord: info.isMainRecord)
            VStack(alignment: .leading, spacing: 4) {
                Text(HabitObj.matchingHabitObj(info.habitType).getName())
                    .typography(.p16SemiBold)
                if let time = info.notificationTime {
                    Text(Date.dailyTimeRecordDateFormat(time, false))
                        .typography(.p14Regular)
                        .foregroundStyle(Color.Gray._400())
                }
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(lineWidth: 1)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(!isCompleted ? Color.Gray._100() : .clear)
                    
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(isCompleted ? .white : Color.Gray._100(), isCompleted ? Color.Primary.main() : .white)
            }
            .onTapGesture {
                withAnimation(.interactiveSpring) {
                    isCompleted.toggle()
                    self.completeAction(info.base.id, isCompleted)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.Gray._50())
        .clipShape(.rect(cornerRadius: 8))
        .onTapGesture {
            coordinator.push(.habitRecordEdit(habitInfo: info, recordVM: recordVM))
        }
        .scaleEffect(pressGesture ? 0.95 : 1.0)
        .contextMenu(menuItems: {
            Button(action: {
                coordinator.push(.habitRecordEdit(habitInfo: info, recordVM: recordVM))
            }, label: {
                Text("수정하기")
            })
            Button(action: {
                Task {
                    let success = await recordVM.deleteHabit(id: info.base.id)
                    sheetVM.visibleToast = success
                    sheetVM.toastMessage = RecordMethod.delete.getMessage()
                }
            }, label: {
                Text("삭제하기")
            })
        })
        .onAppear {
            // info에 isCompleted 가 있다면 값 전달
            if let isCompletion = self.info.isCompleted {
                self.isCompleted = isCompletion
            }
        }
    }
}

#Preview {
    HabitRecordCard(
        info: HabitResponse(
            base: RecordResponse(
                id: "testID",
                type: "EXERCISE",
                recordDate: [2025, 10, 5],
                recordTime: [14, 30],
                createdAt: [2025, 10, 5, 14, 0, 0],
                updatedAt: [2025, 10, 5, 14, 0, 0]
            ), habitType: "EXERCISE", notificationEnabled: true, notificationTime: [14, 20], memo: "굿", isCompleted: false, isMainRecord: true),
        isDismiss: .constant(false),
        completeAction: {_, _ in}
    )
}
