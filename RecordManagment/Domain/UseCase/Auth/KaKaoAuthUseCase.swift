import Foundation

protocol KaKaoAuthUseCase {
    func login() async -> UserState
    func logout() async -> UserState
}

struct DefaultKaKaoLoginUseCase: KaKaoAuthUseCase {
    private let repository: KaKaoLoginRepository
    
    init(repository: KaKaoLoginRepository) {
        self.repository = repository
    }
    
    func login() async -> UserState {
        let accessToken = await repository.requestKaKaoToken()
        guard let accessToken else { return .login }
        
        do {
            let result = try await repository.login(token: accessToken)
            guard let statusCode = result.statusCode else { return .login }
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
            Log.error(error.localizedDescription)
            return .login
        }
    }
    
    func logout() async -> UserState {
        let result = await repository.logout()
        return .login
    }
}
