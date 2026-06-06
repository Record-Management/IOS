import SwiftUI
import Alamofire

/// 로그인 커스텀 에러 입니다.
enum LoginError: Error {
    case accessTokenExpired     // 401
    case refreshTokenExpired    // 401
    case invaildRequest         // 400
    case serverError            // 500
    case networkError(AFError)  // Alamofire 에러
    case unknown(Error)         // 기타
    case notToken               // 토큰이 없습니다
    case invaildURL(String)     // URL이 올바르지 않습니다
    case loginFailed            // 로그인 실패
    case retryTokenPublished    // 토큰 재발급 실패
    case logoutFailed           // 로그아웃 실패
    case withdrawFailed         // 회원 탈퇴 실패
}
