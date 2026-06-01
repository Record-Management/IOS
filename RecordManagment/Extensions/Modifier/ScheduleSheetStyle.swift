import SwiftUI

struct ScheduleSheetStyle: ViewModifier {
    let title: String
    let backAction: () -> Void
    let completeAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                        .onTapGesture { backAction() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Text("완료")
                        .onTapGesture { completeAction() }
                }
            }
    }
}

extension View {
    
    /// 일정 기록 Navigation 스타일입니다.
    /// - Parameters:
    ///   - title: 제목
    ///   - backAction: 뒤로가기 액션
    ///   - completeAction: 완료 액션
    /// - Returns: some View
    func scheduleSheetStyle(title: String, backAction: @escaping () -> Void, completeAction: @escaping () -> Void) -> some View {
        modifier(ScheduleSheetStyle(title: title, backAction: backAction, completeAction: completeAction))
    }
}
