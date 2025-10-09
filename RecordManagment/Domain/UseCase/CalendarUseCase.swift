import Foundation

class CalendarUseCase {
    private let calendarRepository: CalendarRepository
    
    init(calendarRepository: CalendarRepository) {
        self.calendarRepository = calendarRepository
    }
    
    func performTotalCalendar(for date: Date, type: DropDownFilter) async throws-> CalendarRecord {
        try await calendarRepository.fetchTotalDays(for: date, type: type)
    }
}
