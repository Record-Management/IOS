import Foundation

/// 온보딩 과정에서 발생할 수 있는 다양한 오류를 정의하는 열거형입니다.
enum OnBoardingError: Error {
    /// LoginError
    case networkError(LoginError)
    /// 올바르지 않은 응답
    case invalidResponse
    /// 온보딩 완료 통신 실패
    case onBoardingCompleteFailed
    /// 알 수 없는 에러
    case unknown(Error)
}
