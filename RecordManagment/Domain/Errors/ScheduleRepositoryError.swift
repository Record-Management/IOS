import Foundation

/// `ScheduleRepositoryError` Typed Throws 에러 타입
enum ScheduleRepositoryError: LocalizedError {
    // 일정 기록 생성 실패
    case createFailed
    // 일정 기록 수정 실패
    case updateFailed
    // 일정 기록 삭제 실패
    case deleteFailed
    // 유효하지 않은 URL
    case invaildURL
    /// 토큰이 없는 경우
    case notToken
    /// 일정 기록 Limit
    case recordLimit
    /// 서버 에러
    case serverError
    // 다른 에러타입 Wrapper
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .createFailed:
            return "일정 기록 생성 실패"
        case .updateFailed:
            return "일정 기록 수정 실패"
        case .deleteFailed:
            return "일정 기록 삭제 실패"
        case .invaildURL:
            return "유효하지 않은 URL입니다"
        case .notToken:
            return "토큰이 존재하지 않습니다"
        case .recordLimit:
            return "더 이상 기록을 작성 할 수 없습니다"
        case .serverError:
            return "서버에 문제가 있습니다"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
