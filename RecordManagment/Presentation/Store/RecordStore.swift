import SwiftUI

/// 캘린더, 하루, 운동, 습관 기록들의 `Store`
@MainActor
@Observable
final class RecordStore {
    struct State {
        var detailRecords: [IntergrationRecord] = []
        var filterdRecords: [IntergrationRecord] = []
        var currentRecords: [IntergrationRecord] = []
        var detailSchedules: [ScheduleDetail] = []
        var selectedDate: Date = .now
        var recordFilter: DropDownFilter = .all
        var limit: DailyRecordLimit = .default
    }
    
    private(set) var state = State()
    
    // 의존성
    private let calendarRepository: CalendarRepository
    private let scheduleRepository: ScheduleRepository
    
    init(
        calendarRepository: CalendarRepository,
        scheduleRepository: ScheduleRepository
    ) {
        self.calendarRepository = calendarRepository
        self.scheduleRepository = scheduleRepository
    }
    
    enum Intent {
        case fetchRecords(Date)
        case selectDate(Date)
        case setLimit(DailyRecordLimit)
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .fetchRecords(let date):
            Task { await fetchRecords(for: date) }
    
        case .selectDate(let date):
            state.selectedDate = date
            Task { await fetchRecords(for: date) }
        
        case .setLimit(let limit):
            state.limit = limit
        }
    }
}

// MARK: - Private

private extension RecordStore {
    func fetchRecords(for date: Date) async {
        do {
            let (records, schedules) = try await calendarRepository.fetchDateDetailRecords(for: date)
            state.detailRecords = records
            state.detailSchedules = schedules
            state.filterdRecords = records.filter { $0.name == state.recordFilter.name }
            
            if Calendar.current.isDateInToday(date) {
                state.currentRecords = records
            }
        } catch {
            Log.error("detailRecord fetch 실패 : \(error.localizedDescription)")
        }
    }
}
