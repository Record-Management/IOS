import SwiftUI

struct RecordButton: View {
    @Binding var method: RecordMethod
    @Binding var condition: Bool
    @State private var isProcessing = false
    let task: () async -> Void
    
    var body: some View {
        Button(method == .update ? "수정하기" : "작성하기") {
            guard condition && !isProcessing else { return }
            
            isProcessing = true
            Task {
                await task()
                // 클릭 후 0.5초 동안만 클릭을 방지합니다.
                try? await Task.sleep(nanoseconds: 500_000_000)
                isProcessing = false
            }
        }
        .disabled(!condition || isProcessing)
        .seedDaysButtonStyle(type: condition ? .success : .normal, state: .primary)
    }
}
