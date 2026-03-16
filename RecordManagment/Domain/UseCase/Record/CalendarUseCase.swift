import Foundation

protocol CalendarUseCase {
    func performTotalCalendar(for date: Date, type: DropDownFilter) async throws -> CalendarRecord
}

struct DefaultCalendarUseCase: CalendarUseCase {
    private let repository: CalendarRepository
    
    init(repository: CalendarRepository) {
        self.repository = repository
    }
    
    func performTotalCalendar(for date: Date, type: DropDownFilter) async throws -> CalendarRecord {
        try await repository.fetchTotalDays(for: date, type: type)
    }
}

