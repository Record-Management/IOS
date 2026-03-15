import Foundation

struct DefaultCalendarRepository: CalendarRepository {
    private let manager: CalendarNetworkManager
    
    init(manager: CalendarNetworkManager = .init()) {
        self.manager = manager
    }
    
    func fetchTotalDays(for date: Date, type: DropDownFilter) async throws -> CalendarRecord {
        try await manager.fetchCalenderRecordInfo(for: date, type: type)
    }
}
