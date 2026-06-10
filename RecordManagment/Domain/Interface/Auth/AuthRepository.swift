import Foundation

protocol AuthRepository: Sendable {
    /// 소셜 로그인 플랫폼에서 인증을 수행하고 Access Token을 반환합니다.
    func login(socialType: SocialType) async throws -> SocialLoginResponseDTO
    /// 소셜 로그인 플랫폼에서 로그아웃을 수행합니다.
    func logout() async -> Bool
    /// 회원 탈퇴 처리를 진행하고 소셜 연동 해제 및 세션을 삭제합니다.
    func withdraw() async -> Bool
    /// 저장된 토큰으로 자동 로그인을 시도합니다.
    func autoLogin() async throws(LoginError) -> SocialLoginResponseDTO
}
