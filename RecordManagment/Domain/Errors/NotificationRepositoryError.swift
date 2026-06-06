import Foundation

/// 알림 설정 및 내역 관리 관련 네트워크 통신 에러 타입입니다.
enum NotificationRepositoryError: Error, Sendable {
    /// 유효하지 않은 URL
    case inVaildURL(url: String)
    /// 토큰이 존재하지 않음
    case notToken
    /// 알림 내역 조회 실패
    case notificationFetchFailed
    /// 알림 설정 업데이트 실패
    case notificationUpdateFailed
    /// 초기 알림 설정 초기화 실패
    case notificationInitFailed
    
    /// 알 수 없는 기타 에러
    case unknown(Error)
}
