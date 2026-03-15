import Foundation

protocol AppleLoginUseCase {
    func login(authUserData: AuthUserData) async -> UserState
}

struct DefaultAppleLoginUseCase: AppleLoginUseCase {
    private let repository: AppleLoginRepository
    
    init(repository: AppleLoginRepository) {
        self.repository = repository
    }
    
    func login(authUserData: AuthUserData) async -> UserState {
        return await repository.login(authUserData: authUserData)
    }
}
