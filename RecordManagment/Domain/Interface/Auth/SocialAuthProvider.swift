import Foundation

protocol SocialAuthProvider: Sendable {
    /// 소셜 로그인 플랫폼에서 인증을 수행하고 Access Token을 반환합니다.
    func login() async throws -> String
    /// 소셜 로그인 플랫폼에서 로그아웃을 수행합니다.
    func logout() async -> Bool
}