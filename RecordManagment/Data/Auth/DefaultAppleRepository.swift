import Foundation
import AuthenticationServices


struct DefaultAppleRepository: AppleLoginRepository {
    private let manager: LoginNetworkManager
    
    init(manager: LoginNetworkManager = .init()) {
        self.manager = manager
    }
    
    func login(authUserData: AuthUserData) async -> Result<SocialLoginResponseDTO, LoginError>? {
        guard !authUserData.token.isEmpty else { return nil }
        
        do {
            return try await manager.login(socialType: .apple, accessToken: authUserData.token)
        } catch {
            debugPrint("Apple Login Repository Error : \(error)")
            return .failure(.unknown(error))
        }
    }
}
