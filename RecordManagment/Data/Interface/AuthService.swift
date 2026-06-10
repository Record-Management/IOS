import Foundation

/// 인증 및 로그인 관련 비즈니스 로직을 처리하는 Service 인터페이스입니다.
protocol AuthService: Sendable {
    /// 소셜 로그인(카카오, 애플 등)을 수행합니다.
    ///
    /// - Parameters:
    ///   - type: 로그인을 진행할 소셜 로그인 플랫폼 유형 (`SocialType`)
    ///   - token: 소셜 플랫폼으로부터 발급받은 Access Token
    /// - Returns: 서버로부터 전달받은 로그인 응답 결과 (`SocialLoginResponseDTO`)
    /// - Throws: 로그인 처리 실패 시 `LoginError` 에러를 전달합니다.
    func login(socialType type: SocialType, accessToken token: String) async throws(LoginError) -> SocialLoginResponseDTO
        
    /// 저장된 정보를 바탕으로 로그인 인증 토큰의 유효성을 검증하고 갱신합니다.
    ///
    /// - Returns: 인증 토큰 검증 및 갱신 성공 시의 응답 결과 (`SocialLoginResponseDTO`)
    /// - Throws: 토큰 만료 또는 유효하지 않은 인증 정보일 때 `LoginError` 에러를 전달합니다.
    func authorizationToken() async throws(LoginError) -> SocialLoginResponseDTO
    
    /// 로그아웃을 요청하고 기기에 저장된 세션을 해제합니다.
    ///
    /// - Returns: 로그아웃 완료 여부 (`true` 시 성공)
    /// - Throws: 로그아웃 처리 실패 시 `LoginError` 에러를 전달합니다.
    @discardableResult
    func logout() async throws(LoginError) -> Bool
        
    /// 회원 탈퇴 처리를 진행하고 모든 계정 연동을 해제합니다.
    ///
    /// - Parameter reason: 탈퇴 사유 (선택 사항)
    /// - Returns: 탈퇴 성공 여부 (`true` 시 성공)
    /// - Throws: 회원 탈퇴 실패 시 `LoginError` 에러를 전달합니다.
    @discardableResult
    func WithdrawMembership(reason: String?) async throws(LoginError) -> Bool
}
