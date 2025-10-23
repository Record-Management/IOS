import SwiftUI
import Combine

class MainSheetViewModel: ObservableObject {
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
        getIsCompletedsubscriber() // isCompletion for Habit
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
    func getIsCompletedPublisher() -> AnyPublisher<Bool, Never> {
        $isCompleted
            .receive(on: RunLoop.main)
            .debounce(for: .milliseconds(500) ,scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getIsCompletedsubscriber() {
        getIsCompletedPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case .failure(let err):
                    debugPrint("habit Completion err: \(err)")
                }
            }, receiveValue: { [weak self] val in
                guard let type = self?.type, let recordId = self?.recordId else { return }
                if type == "HABIT" {
                    Task {
                        do {
                            try await self?.useCase.fetch(val, recordId: recordId)
                        } catch {
                            debugPrint("fetch Error : \(error)")
                        }
                    }
                } else {
                    debugPrint("isComplete is Not Habit Type")
                }
            }).store(in: &cancellables)
    }
}
