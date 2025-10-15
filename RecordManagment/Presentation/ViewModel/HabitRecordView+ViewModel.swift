import SwiftUI

extension HabitRecordView {
    class ViewModel: ObservableObject {
        @Published var habit: HabitObj
        @Published var sheet: Bool = false
        @Published var memo: String = ""
        @Published var method: RecordMethod
        @Published var isDismiss: Bool = false
        
        init(habit: HabitObj, method: RecordMethod) {
            self.habit = habit
            self.method = method
        }
    }
}
