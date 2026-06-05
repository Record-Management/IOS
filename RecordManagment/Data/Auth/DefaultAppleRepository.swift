import Foundation
import AuthenticationServices


struct DefaultAppleRepository: AppleLoginRepository {
    private let service: AuthService
    
    init(service: AuthService) {
        self.service = service
    }
    
    func login(authUserData: AuthUserData) async throws(LoginError) -> SocialLoginResponseDTO {
        guard !authUserData.token.isEmpty else {
            Log.network("AccessToken이 비어있습니다", isError: true)
            throw .accessTokenExpired
        }
        
        do {
            return try await service.login(socialType: .apple, accessToken: authUserData.token)
        } catch {
            Log.error(error.localizedDescription)
            throw .loginFailed
        }
    }
}
