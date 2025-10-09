import Foundation

protocol CalendarRepository {
    // 특정 Month의 전체 기록 가져오는 함수
    func fetchTotalDays(for date: Date, type: DropDownFilter) async throws -> CalendarRecord
}
