import SwiftUI

struct HabitRecordCard: View {
    @EnvironmentObject var coordinator: Coordinator
    @GestureState private var isDetectingLongPress: Bool = false
    @Binding var isDismiss: Bool
    @Binding var isCompleted: Bool
    
    let info: HabitResponse
    let action: (String, String) -> Void
    
    init(info: HabitResponse, isDismiss: Binding<Bool>, isCompleted: Binding<Bool> ,action: @escaping (String, String) -> Void) {
        self.info = info
        self._isDismiss = isDismiss
        self._isCompleted = isCompleted
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white)
                Image(info.habitType)
                    .resizable()
                    .scaledToFit().frame(maxWidth: 50, maxHeight: 50)
            }
            .frame(maxWidth: 66, maxHeight: 66)
            Text(HabitObj.matchingHabitObj(info.habitType).getName())
                .typography(.p16SemiBold)
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
                    action(info.base.id, info.base.type)
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
        .scaleEffect(isDetectingLongPress ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.5), value: isDetectingLongPress)
        .gesture(longPress)
        .onAppear {
            // info에 isCompleted 가 있다면 값 전달
            if let isCompletion = self.info.isCompleted {
                self.isCompleted = isCompletion
            }
        }
    }
    
    // Long Press Gesture
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .updating($isDetectingLongPress) { current, gesture, _ in
                withAnimation(.easeInOut(duration: 0.1)) {
                    gesture = current
                }
            }
            .onEnded { _ in
                withAnimation(.spring) {
                    isDismiss = true
                }
                action(info.base.id, info.base.type)
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
            ), habitType: "EXERCISE", notificationEnabled: true, notificationTime: [14, 20], memo: "굿", isCompleted: false),
        isDismiss: .constant(false),
        isCompleted: .constant(false),
        action: {_, _ in})
}
