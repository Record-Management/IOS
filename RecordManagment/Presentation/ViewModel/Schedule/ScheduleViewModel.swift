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
    @Published private(set) var dismissSheet: Bool = false
    @Published var activateButton: Bool = true
    /// Sheet Flag State
    @Published var showNotificationSheet: Bool = false
    @Published var showRepeatSheet: Bool = false
    @Published var showColorSheet: Bool = false
    
    @Published var method: RecordMethod = .create
    @Published var scheduleId: String? = nil
    @Published var isDismiss: Bool = false
    
    var format: ScheduleFormat {
        .init(
            title: title,
            startDate: Date.convertArrayForDate(startDate),
            endDate: Date.convertArrayForDate(endDate),
            notificationType: notification.type.format,
            notificationCustomHours: notification.customHours,
            notificationCustomMinutes: notification.customMinute,
            repeatType: repeatData.format,
            repeatEndsOn: Date.scheduleBody(repeatData.endsOn),
            location: location.isEmpty ? nil : location,
            color: color.format,
            memo: memo.isEmpty ? nil : memo
        )
    }
    
    /// DI
    private let repository: any ScheduleRepository
    
    init(
        repository: any ScheduleRepository,
        scheduleResponse: ScheduleResponse? = nil
    ) {
        self.repository = repository
        if let response = scheduleResponse {
            self.method = .update
            self.scheduleId = response.scheduleId
            injectResponse(response)
        } else {
            self.method = .create
        }
    }
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
    
    func create() async -> Bool {
        do {
            let res = try await repository.create(form: format)
            injectResponse(res)
            dismissSheet = true
            return true
        } catch {
            debugPrint("ScheduleViewModel Error: \(error)")
            return false
        }
    }
    
    func update() async -> Bool {
        guard let scheduleId = scheduleId else { return false }
        do {
            debugPrint(format)
            let res = try await repository.update(scheduleId: scheduleId, form: format)
            injectResponse(res)
            dismissSheet = true
            return true
        } catch {
            debugPrint("ScheduleViewModel Update Error: \(error)")
            return false
        }
    }
    
    func delete() async -> Bool {
        guard let scheduleId = scheduleId else { return false }
        do {
            try await repository.delete(scheduleId: scheduleId)
            dismissSheet = true
            return true
        } catch {
            debugPrint("ScheduleViewModel Delete Error: \(error)")
            return false
        }
    }
    
    
    func injectResponse(_ detail: ScheduleResponse) {
        self.title = detail.title
        self.memo = detail.memo ?? ""
        self.location = detail.location ?? ""
        self.startDate = Date.convertDateForIntArray(detail.startDate) ?? .now
        self.endDate = Date.convertDateForIntArray(detail.endDate) ?? .now
        
        let notiType = ScheduleNotification.NotificationType.allCases.first(where: { $0.format == detail.notificationType }) ?? .none
        if case .custom = notiType {
            self.notification = ScheduleNotification(type: .custom(detail.notificationCustomHours, detail.notificationCustomMinutes))
        } else {
            self.notification = ScheduleNotification(type: notiType)
        }
        
        let repType = ScheduleRepeat.RepeatType.allCases.first(where: { $0.format == detail.repeatType }) ?? .none
        self.repeatData = ScheduleRepeat(type: repType, endsOn: detail.repeatEndsOn)
        
        self.color = ScheduleColor.matchingColor(detail.color)
    }
}

// MARK: - Observve

extension ScheduleViewModel {
    func observeActivateRecordButton() {
        let publisher = $title
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
        
        publisher.assign(to: &$activateButton)
    }
}
