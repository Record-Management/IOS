import Foundation
import KakaoSDKUser

@MainActor
struct KaKaoAuthProvider: SocialAuthProvider {
    func login() async throws -> String {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            return try await kakaoAppLaunchedLogin()
        } else {
            return try await kakaoWebViewLogin()
        }
    }
    
    func logout() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.logout {(error) in
                if let error = error {
                    Log.error(error.localizedDescription)
                    continuation.resume(returning: false)
                }
                else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
}

// MARK: - Private

extension KaKaoAuthProvider {
    // TODO: 카카오톡이 설치된 경우 Login logic
    func kakaoAppLaunchedLogin() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    Log.error(error.localizedDescription)
                    continuation.resume(throwing: error)
                    return
                }
                guard let oauthToken else {
                    Log.error("oauthToken이 없습니다.")
                    continuation.resume(throwing: LoginError.notToken)
                    return
                }
                Log.info("loginWithKakaoTalk() success.")
                continuation.resume(returning: oauthToken.accessToken)
            }
        }
    }
    
    // TODO: 카카오톡 설치 안된 경우 -> 웹뷰
    func kakaoWebViewLogin() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    Log.error(error.localizedDescription)
                    continuation.resume(throwing: error)
                    return
                }
                guard let oauthToken else {
                    Log.error("oauthToken이 없습니다.")
                    continuation.resume(throwing: LoginError.notToken)
                    return
                }
                
                Log.info("loginWithKakaoAccount() success.")
                continuation.resume(returning: oauthToken.accessToken)
            }
        }
    }
}
