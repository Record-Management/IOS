import SwiftUI
import Combine

@MainActor
final class MainSheetViewModel: ObservableObject {
    @Published var scrollOffset: CGFloat = 0
    @Published var sheetState: SheetState = .medium
    @Published var visibleToast: Bool = false
    @Published var toastMessage: String = "기록 저장이 완료 되었습니다."
    @Published var error: RecordError? = nil
    @Published var isDismiss: Bool = false
    @Published var isCompleted: Bool = false
    @Published var recordId: String?
    @Published var type: String?
    
    private var cancellables = Set<AnyCancellable>()
    let useCase: MainSheetUseCase
    
    init(useCase: MainSheetUseCase) {
        self.useCase = useCase
        toastSubscriber()          // Toast Message
    }
    
    // TODO: Toast Publisher
    func toastPublisher() -> AnyPublisher<Bool, Never> {
        $visibleToast
            .removeDuplicates()
            .map { $0 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    // TODO: Toast Subscriber
    func toastSubscriber() {
        toastPublisher()
            .sink( receiveValue: { val in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation {
                        self.visibleToast = false
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    // sheet Drag Gesture Event
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


extension MainSheetViewModel {
    func updateCompletedHabit(recordId: String, isCompleted: Bool) async {
        do {
            try await self.useCase.fetch(isCompleted, recordId: recordId)
        } catch {
            debugPrint("fetch Error : \(error)")
        }
    }
}
