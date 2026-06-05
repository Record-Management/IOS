import SwiftUI
import KakaoSDKUser

/// KaKao 로그인 구현체
struct DefaultKaKaoRepository: KaKaoLoginRepository {
    private let service: AuthService
    
    init(service: AuthService) {
        self.service = service
    }
    
    func login(token: String) async throws(LoginError) -> SocialLoginResponseDTO {
        try await service.login(socialType: .kakao, accessToken: token)
    }
    
    func logout() async -> Bool {
        await kakaoLogout()
        do {
            return try await service.logout()
        } catch {
            Log.error(error.localizedDescription)
            return false
        }
    }
    
    // TODO: Token값 불러오는 함수
    func requestKaKaoToken() async -> String? {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            await kakaoAppLaunchedLogin()
        } else {
            await kakaoWebViewLogin()
        }
    }
}


// MARK: Private - 로그인( 인앱, 웹뷰 ), 로그아웃 - 비지니스 로직
private extension DefaultKaKaoRepository {
    
    // TODO: 카카오톡이 설치된 경우 Login logic
    func kakaoAppLaunchedLogin() async -> String? {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    debugPrint(error)
                }
                else {
                    debugPrint("loginWithKakaoTalk() success.")
                }
                continuation.resume(returning: oauthToken?.accessToken)
            }
        }
    }
    
    // TODO: 카카오톡 설치 안된 경우 -> 웹뷰
    func kakaoWebViewLogin() async -> String? {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    debugPrint(error)
                }
                else {
                    debugPrint("loginWithKakaoAccount() success.")
                }
                continuation.resume(returning: oauthToken?.accessToken)
            }
        }
    }
    
    // TODO: 카카오 로그아웃
    @discardableResult
    func kakaoLogout() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.logout {(error) in
                if let error = error {
                    debugPrint(error)
                    continuation.resume(returning: false)
                }
                else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
}
