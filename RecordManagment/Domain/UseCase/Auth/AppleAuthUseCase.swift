import Foundation

protocol AppleAuthUseCase {
    func login(authUserData: AuthUserData) async -> UserState
}

struct DefaultAppleLoginUseCase: AppleAuthUseCase {
    private let repository: AppleLoginRepository
    
    init(repository: AppleLoginRepository) {
        self.repository = repository
    }
    
    func login(authUserData: AuthUserData) async -> UserState {
        do {
            let result = try await repository.login(authUserData: authUserData)
            guard let statusCode = result.statusCode else {
                return .login
            }
            switch statusCode {
            case 200:
                // 신규 사용자 또는 온보딩 미완료 체크
                guard
                    let response = result.data,
                    let isNewUser = response.newUser,
                    let user = response.user
                else { return .login }
                if user.onboardingCompleted || isNewUser {
                    return .register
                } else {
                    return .main
                }
            case 201:
                Log.info("신규 사용자입니다")
                return .register
            default:
                return .login
            }
        } catch {
            Log.error("애플 로그인 실패 : \(error.localizedDescription)")
            return .login
        }
    }
}
