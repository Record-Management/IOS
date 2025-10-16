import SwiftUI

struct HabitRecordCard: View {
    @EnvironmentObject var coordinator: Coordinator
    let info: HabitResponse
    @Binding var isDismiss: Bool
    let action: (String, String) -> Void
    @GestureState private var isDetectingLongPress: Bool = false
    
    init(info: HabitResponse, isDismiss: Binding<Bool>, action: @escaping (String, String) -> Void) {
        self.info = info
        self._isDismiss = isDismiss
        self.action = action
    }
    
    var body: some View {
        Text("Habit card 입니다")
    }
}
