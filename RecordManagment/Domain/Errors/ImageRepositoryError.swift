import Foundation

enum ImageRepositoryError: Error, Sendable {
    /// 유효하지 않은 URL
    case inVaildURL(url: String)
    /// 토큰이 존재하지 않음
    case notToken
    /// 이미지 업로드 실패
    case uploadFailed
    /// 이미지 가져오기 실패
    case fetchFailed
    /// 알 수 없는 기타 에러
    case unknown(Error)
}
