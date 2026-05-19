import Foundation
import Combine

@MainActor
final class ScheduleViewModel: ObservableObject {
    @Published private(set) var title: String = ""
    @Published private(set) var memo: String = ""
    @Published private(set) var location: String = ""
    @Published private(set) var startDate: Date = .now
    @Published private(set) var endDate: Date = .now
    @Published private(set) var dateProgress: PickerProgress = .none
    @Published private(set) var repeatData: ScheduleRepeat = .default
    @Published private(set) var notification: ScheduleNotification = .default
    @Published private(set) var color: ScheduleColor = .Orange
    @Published private(set) var saveState: SaveState = .none
    @Published private(set) var activateButton: Bool = false
    /// Sheet Flag State
    @Published var showNotificationSheet: Bool = false
    @Published var showRepeatSheet: Bool = false
    @Published var showColorSheet: Bool = false
}

// MARK: - Setter / Getter

extension ScheduleViewModel {
    func setTitle(_ title: String) {
        self.title = title
    }
    
    func setMemo(_ memo: String) {
        self.memo = memo
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
        self.dateProgress = progress
    }
    
    func setNotification(_ notification: ScheduleNotification) {
        self.notification = notification
    }
    
    func setRepeatData(_ repeatData: ScheduleRepeat) {
        self.repeatData = repeatData
    }
    
    func setColor(_ color: ScheduleColor) {
        self.color = color
    }
    
    func setSave(_ state: SaveState) {
        self.saveState = state
        switch saveState {
        case .none:
            return
        case .exit(let data):
            switch data {
            case .notification(let oldValue):
                setNotification(oldValue)
            case .repeat(let oldValue):
                setRepeatData(oldValue)
            case .color(let oldValue):
                setColor(oldValue)
            }
        }
    }
}

// MARK: - Actions

extension ScheduleViewModel {
    func datePickerCompleteButtonTapped() {
        dateProgress = .none
    }
}
