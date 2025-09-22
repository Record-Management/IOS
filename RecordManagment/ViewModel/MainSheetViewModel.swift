import SwiftUI
import Combine

class MainSheetViewModel: ObservableObject {
    @Published var visibleToast: Bool = false
    @Published var toastMessage: String = "기록 저장이 완료 되었습니다."
    private var cancellables = Set<AnyCancellable>()
    var recordService = RecordService.shared
    
    init() {
        recordService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
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
}
