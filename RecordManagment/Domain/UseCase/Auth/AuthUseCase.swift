import Foundation

protocol AuthUseCase {
    /// 소셜 로그인 플랫폼에서 인증을 수행하고 Access Token을 반환합니다.
    func login(socialType: SocialType) async -> AuthState
    /// 소셜 로그인 플랫폼에서 로그아웃을 수행합니다.
    func logout() async -> AuthState
    /// 회원 탈퇴 처리를 진행하고 소셜 연동 해제 및 세션을 삭제합니다.
    func withdraw() async -> AuthState
    /// 자동 로그인을 수행합니다.
    func autoLogin() async -> AuthState
}

/// 로그인 상태를 전달할 유즈케이스입니다.
struct DefaultAuthUseCase: AuthUseCase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func login(socialType: SocialType) async -> AuthState {
        do {
            let result = try await repository.login(socialType: socialType)
            guard let statusCode = result.statusCode else {
                return .login
            }
            
            switch statusCode {
            case 200:
                guard let response = result.data,
                      let isNewUser = response.newUser,
                      let user = response.user
                else { return .login }
                
                if !user.onboardingCompleted || isNewUser {
                    return .register
                } else {
                    return .main
                }
            case 201:
                Log.info("신규 사용자입니다 (온보딩으로 이동)")
                return .register
            default:
                return .login
            }
        } catch {
            Log.error("\(socialType.rawValue) 로그인 실패: \(error.localizedDescription)")
            return .login
        }
    }
    
    func logout() async -> AuthState {
        _ = await repository.logout()
        return .login // 실패하더라도 무조건 로그인 화면행 정책 반영
    }
    
    func withdraw() async -> AuthState {
        _ = await repository.withdraw()
        return .login // 실패하더라도 무조건 로그인 화면행 정책 반영
    }
    
    func autoLogin() async -> AuthState {
        do {
            let result = try await repository.autoLogin()
            guard let statusCode = result.statusCode else {
                return .login
            }
            
            switch statusCode {
            case 200:
                guard let response = result.data,
                      let user = response.user
                else {
                    return .login
                }
                
                if !user.onboardingCompleted {
                    return .register
                } else {
                    return .main
                }
            case 201:
                return .register
            default:
                return .login
            }
        } catch {
            Log.error("자동 로그인 실패: \(error.localizedDescription)")
            return .login
        }
    }
}
