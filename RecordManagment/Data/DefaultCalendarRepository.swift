import Foundation

class DefaultCalendarRepository: CalendarRepository {
    let manager: CalendarNetworkManager = .init()
    
    func fetchTotalDays(for date: Date, type: DropDownFilter) async throws -> CalendarRecord {
        try await manager.fetchCalenderRecordInfo(for: date, type: type)
    }
}
