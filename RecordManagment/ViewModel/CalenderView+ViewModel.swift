import SwiftUI

extension CalenderView {
    class ViewModel: ObservableObject {
        @Published var date = Date.now
        @Published var color: Color = .blue
        @Published var selectedDay: Date? = .now
        @Published var isFilterBox: Bool = false
        @Published var currentRecord: DropDownFilter = .all
        
        
        // TODO: 좌우 스크롤 이벤트 함수
        func horizontalScrollGesture() -> _EndedGesture<DragGesture>{
            DragGesture().onEnded { value in
                if value.translation.width < -50 {
                    if let next = Calendar.current.date(byAdding: .month, value: 1, to: self.date) {
                        withAnimation(.smooth) {
                            self.date = next
                        }
                    }
                } else if value.translation.width > 50 {
                    if let prev = Calendar.current.date(byAdding: .month, value: -1, to: self.date) {
                        withAnimation(.smooth) {
                            self.date = prev
                        }
                    }
                }
            }
        }
    }
}
