import SwiftUI
import KakaoSDKUser

// MARK: UseCase login, logout
class DefaultKaKaoRepository: KaKaoLoginRepository {
    
    let manager: LoginNetworkManager = .init()
    
    func login(token: String) async -> Result<SocialLoginResponseDTO, LoginError>? {
        try? await manager.login(socialType: .kakao, accessToken: token)
    }
    
    func logout() async {
        await kakaoLogout()
        await manager.logout()
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


// MARK: 로그인( 인앱, 웹뷰 ), 로그아웃 - 비지니스 로직
extension DefaultKaKaoRepository {
    
    // TODO: 카카오톡이 설치된 경우 Login logic
    @MainActor
    func kakaoAppLaunchedLogin() async -> String? {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                }
                continuation.resume(returning: oauthToken?.accessToken)
            }
        }
    }
    
    // TODO: 카카오톡 설치 안된 경우 -> 웹뷰
    @MainActor
    func kakaoWebViewLogin() async -> String? {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                }
                continuation.resume(returning: oauthToken?.accessToken)
            }
        }
    }
    
    // TODO: 카카오 로그아웃
    @MainActor @discardableResult
    func kakaoLogout() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.logout {(error) in
                if let error = error {
                    print(error)
                    continuation.resume(returning: false)
                }
                else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
}
