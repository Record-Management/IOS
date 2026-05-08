import Foundation
import Combine

@MainActor
final class ScheduleViewModel: ObservableObject {
    @Published private(set) var text: String = ""
    @Published private(set) var multiText: String = ""
    @Published private(set) var location: String = ""
    @Published private(set) var startDate: Date = .now
    @Published private(set) var endDate: Date = .now
    @Published private(set) var dateProgress: PickerProgress = .none
    
    enum PickerProgress: Equatable {
        case start          // 시작 날짜
        case end            // 마지막 날짜
        case none           // wheel picker 안보이는 상태
    }
}

// MARK: - Setter / Getter

extension ScheduleViewModel {
    func setText(_ text: String) {
        self.text = text
    }
    
    func setMultiText(_ multiText: String) {
        self.multiText = multiText
    }
    
    func setLocation(_ location: String) {
        self.location = location
    }
    
    func setStartDate(_ startDate: Date) {
        self.startDate = startDate
        
        if self.startDate > self.endDate {
            self.endDate = self.startDate
        }
    }
    
    func setEndDate(_ endDate: Date) {
        if endDate < startDate {
            self.endDate = startDate
            return
        }
        
        self.endDate = endDate
    }
    
    func setDateProgress(_ progress: PickerProgress) {
        dateProgress = progress
    }
}

// MARK: - Actions

extension ScheduleViewModel {
    func datePickerCompleteButtonTapped() {
        dateProgress = .none
    }
}
