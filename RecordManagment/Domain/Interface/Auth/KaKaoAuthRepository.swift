import Foundation

protocol KaKaoLoginRepository {
    // 카카오 인증 Token 요청 함수
    func requestKaKaoToken() async -> String?
    // Login
    func login(token: String) async throws(LoginError) -> SocialLoginResponseDTO
    // logout
    func logout() async -> Bool
}
