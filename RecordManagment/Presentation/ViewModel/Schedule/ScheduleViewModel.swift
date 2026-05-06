import Foundation

final class ScheduleViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var multiText: String = ""
    @Published var location: String = ""
    @Published var startDate: Date = .now
    @Published var endDate: Date = .now
    @Published var dateProgress: PickerProgress = .none

    enum PickerProgress: Equatable {
        case start          // 시작!
        case change         // endDate wheel picker 전환
        case none           // wheel picker 안보이는 상태
    }
    
    func setDateProgress(_ progress: PickerProgress) {
        dateProgress = progress
    }
    
    func datePickerCompleteButtonTapped() {
        switch dateProgress {
        case .start:
            dateProgress = .change
        case .change, .none:
            dateProgress = .none
        }
    }
}
