import Foundation

/// 애플 로그인을 처리하는 리포지토리의 인터페이스입니다.
protocol AppleLoginRepository {
    
    /// 애플 사용자 인증 정보를 사용하여 로그인을 수행합니다.
    ///
    /// - Parameter authUserData: 애플 로그인 성공 후 전달받은 사용자 인증 데이터
    /// - Throws: `LoginError` 를 채택합니다
    /// - Returns: 로그인 성공 시 DTO를 포함하고, 실패 시 `LoginError`를 포함하는 `Result` 객체를 반환합니다.
    ///            처리가 취소되거나 완료되지 않은 경우 `nil`을 반환할 수 있습니다.
    func login(authUserData: AuthUserData) async throws(LoginError) -> SocialLoginResponseDTO
}
