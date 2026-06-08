import Foundation

struct DefaultAuthRepository: AuthRepository {
    private let providers: [SocialType: SocialAuthProvider]
    private let authService: AuthService
    private let keyChain: KeyChainManager
    
    init(
        providers: [SocialType: SocialAuthProvider],
        authService: AuthService,
        keyChain: KeyChainManager
    ) {
        self.providers = providers
        self.authService = authService
        self.keyChain = keyChain
    }

    func login(socialType: SocialType) async throws -> SocialLoginResponseDTO {
        guard let provider = providers[socialType] else {
            Log.error("Unsupported social type: \(socialType)")
            throw LoginError.invaildRequest
        }
        
        let accessToken = try await provider.login()
        let response = try await authService.login(socialType: socialType, accessToken: accessToken)
        
        // socialType 저장
        await keyChain.create(account: DataPolicy.socialType, data: socialType.rawValue)
        
        return response
    }
    
    func logout() async -> Bool {
        guard let rawType = await keyChain.read(account: DataPolicy.socialType),
              let socialType = SocialType(rawValue: rawType) else {
            // 소셜 타입 정보가 없더라도 공통 서버 로그아웃은 수행
            return await performServerLogout()
        }
        
        // 해당 소셜 SDK 로그아웃 실행
        if let provider = providers[socialType] {
            _ = await provider.logout()
        }
        
        return await performServerLogout()
    }
    
    func withdraw() async -> Bool {
        guard let rawType = await keyChain.read(account: DataPolicy.socialType),
              let socialType = SocialType(rawValue: rawType) else {
            return false
        }
        
        do {
            let isWithdrawSuccess = try await authService.WithdrawMembership(reason: nil)
            guard isWithdrawSuccess else { return false }
            
            // 서버 회원 탈퇴 성공 시에만 소셜 SDK 로그아웃 및 Keychain 삭제 진행
            if let provider = providers[socialType] {
                _ = await provider.logout()
            }
            await keyChain.delete(account: DataPolicy.socialType)
            return true
        } catch {
            Log.error("회원 탈퇴 실패: \(error)")
            return false
        }
    }
    
    func autoLogin() async throws(LoginError) -> SocialLoginResponseDTO {
        return try await authService.authorizationToken()
    }
    
    private func performServerLogout() async -> Bool {
        do {
            let isServerLogoutSuccess = try await authService.logout()
            if isServerLogoutSuccess {
                await keyChain.delete(account: DataPolicy.socialType)
            }
            return isServerLogoutSuccess
        } catch {
            Log.error("서버 로그아웃 실패: \(error)")
            return false
        }
    }
}
