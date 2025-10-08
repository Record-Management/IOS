import SwiftUI
import Combine

class MainSheetViewModel: ObservableObject {
    @Published var scrollOffset: CGFloat = 0
    @Published var sheetState: SheetState = .medium
    @Published var visibleToast: Bool = false
    @Published var toastMessage: String = "기록 저장이 완료 되었습니다."
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        toastPublisher()
            .sink( receiveValue: { val in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation {
                        self.visibleToast = false
                    }
                }
                print(self.visibleToast)
            })
            .store(in: &cancellables)
    }
    
    func toastPublisher() -> AnyPublisher<Bool, Never> {
        $visibleToast
            .removeDuplicates()
            .map { $0 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func dragSheetGesture() -> _EndedGesture<DragGesture> {
        DragGesture()
            .onEnded { value in
                let move = value.translation.height
                
                guard self.scrollOffset <= 0 else { return }
                
                if move > 100 {
                    SheetState.down(&self.sheetState)
                } else if move < -100 {
                    SheetState.up(&self.sheetState)
                }
            }
    }
}
