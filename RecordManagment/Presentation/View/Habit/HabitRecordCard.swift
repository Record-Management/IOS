import SwiftUI

struct HabitRecordCard: View {
    @EnvironmentObject var coordinator: Coordinator
    @Bindable var store: MainStore

    // View Properties
    @State private var pressGesture: Bool = false
    @Binding var isDismiss: Bool
    @State private var isCompleted: Bool = false
    
    let info: HabitResponse
    let completeAction: (String ,Bool) -> Void
    
    init(
        info: HabitResponse,
        isDismiss: Binding<Bool>,
        store: MainStore,
        completeAction: @escaping (String, Bool) -> Void
    ) {
        self.info = info
        self._isDismiss = isDismiss
        self.store = store
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
                if let time = info.notificationTime, !time.isEmpty {
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
            coordinator.push(.habitRecordEdit(habitInfo: info))
        }
        .scaleEffect(pressGesture ? 0.95 : 1.0)
        .onLongPressGesture {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        .contextMenu(menuItems: {
            Button(action: {
                coordinator.push(.habitRecordEdit(habitInfo: info))
            }, label: {
                Text("수정하기")
            })
            Button(action: {
//                store.recordStore.send(.deleteHabit(id: info.base.id))
            }, label: {
                Text("삭제하기")
            })
        })
        .onAppear {
            if let isCompletion = self.info.isCompleted {
                self.isCompleted = isCompletion
            }
        }
    }
}
