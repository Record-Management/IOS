import Foundation

/// (하루, 운동 , 습관)기록 Network 통신 전용 커스텀 에러타입입니다.
enum RecordRepositoryError: Error, Sendable {
    /// 유효하지 않은 Date
    case inVaildDate(date: Date)
    /// 유효하지 않은 URL
    case inVaildURL(url: String)
    /// 유효하지 않은 토큰
    case notToken
    /// 기록 제한
    case recordLimit
    /// 하루기록 작성 실패
    case dailyCreateFailed
    /// 운동기록 작성 실패
    case exerciseCreateFailed
    /// 습관기록 작성 실패
    case habitCreateFailed
    /// 알 수 없는 에러
    case unknown(Error)
}
