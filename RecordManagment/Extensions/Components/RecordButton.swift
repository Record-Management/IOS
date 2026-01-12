import SwiftUI

struct RecordButton: View {
    @Binding var method: RecordMethod
    @Binding var condition: Bool
    let task: () async -> Void
    
    var body: some View {
        Button(method == .update ? "수정하기" : "작성하기") {
            guard condition else { return }
            Task {
                await task()
            }
        }
        .seedDaysButtonStyle(type: condition ? .success : .normal, state: .primary)
    }
}
