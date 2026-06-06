import Foundation

protocol CalendarRepository {
    /// 특정 Month(월)의 전체 기록 요약 정보를 가져옵니다. (캘린더 월간 뷰의 날짜별 기록 여부 표시용)
    /// - Parameters:
    ///   - date: 조회하고자 하는 년/월 정보가 포함된 날짜
    ///   - type: 필터링할 기록 종류 (All, Daily, Exercise, Habit 등)
    /// - Returns: 월간 기록 요약 데이터 (`CalendarRecord`)
    func fetchTotalDays(for date: Date, type: DropDownFilter) async throws(CalendarError) -> CalendarRecord
    
    /// 특정 일자(일)의 통합 상세 기록 목록(일기, 운동, 습관 등)을 가져옵니다. (캘린더 일자 선택 시 하단 상세 목록 표시용)
    /// - Parameter date: 상세 기록을 조회할 특정 날짜
    /// - Returns: 해당 일자에 등록된 통합 기록 리스트 (`([IntergrationRecord], [ScheduleDetail])`)
    func fetchDateDetailRecords(for date: Date) async throws(CalendarError) -> ([IntergrationRecord], [ScheduleDetail])
}
