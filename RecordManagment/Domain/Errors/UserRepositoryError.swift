import Foundation

/// 사용자 정보 및 프로필 관리 관련 네트워크 통신 에러 타입입니다.
enum UserRepositoryError: Error, Sendable {
    /// 유효하지 않은 URL
    case inVaildURL(url: String)
    /// 토큰이 존재하지 않음
    case notToken
    /// 프로필 업데이트 실패
    case profileUpdateFailed
    /// 내 정보 가져오기 실패
    case fetchMyInfoFailed
    
    /// 알 수 없는 기타 에러
    case unknown(Error)
}
