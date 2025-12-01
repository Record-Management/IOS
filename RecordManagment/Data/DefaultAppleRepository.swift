import Foundation
import AuthenticationServices


class DefaultAppleRepository: AppleLoginRepository {
    let manager: LoginNetworkManager = .init()
    
    func login(authUserData: AuthUserData) async -> UserState {
        var result: Result<SocialLoginResponseDTO, LoginError>? = nil

        if !authUserData.token.isEmpty {
            do {
                result = try await manager.login(socialType: .apple, accessToken: authUserData.token)
            } catch {
                debugPrint("err : \(error)")
            }
            
            switch result {
            case .success(let response):
                debugPrint("kakao login result : \(response)")
                switch response.statusCode {
                case 200:
                    debugPrint("기존 사용자입니다")
                    if let data = response.data {
                        if let user = data.newUser,
                           let completed = data.user?.onboardingCompleted,
                           user || !completed {
                            debugPrint("기존 사용자인척 하는 신규 사용자입니다.")
                            return .register
                        }
                    }
                    return .main
                case 201:
                    debugPrint("신규 사용자립니다")
                    return .register
                default:
                    return .login
                }
            case .failure(let err):
                debugPrint("kakoLogin Error : \(err.localizedDescription)")
                return .login
            case .none:
                return .login
            }
        } else {
            return .login
        }
    }
}
