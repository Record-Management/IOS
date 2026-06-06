import Foundation

/// 캘린더 Network 통신 전용 커스텀 에러타입입니다.
enum CalendarError: Error, Sendable {
    /// 유효하지 않은 Date
    case inVaildDate(date: Date)
    /// 유효하지 않은 URL
    case inVaildURL(url: String)
    /// 유효하지 않은 토큰
    case notToken
    /// 캘린더 전체 조회 실패
    case fetchTotalCalendarFailed
    /// 캘린더 date조회 실패
    case fetchDateOnCalendarFailed
    /// 알 수 없는 에러
    case unknown(Error)
}
