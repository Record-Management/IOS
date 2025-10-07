import Foundation

class AppleLoginUseCase {
    private let appleRepository: AppleLoginRepository
    
    init(appleRepository: AppleLoginRepository) {
        self.appleRepository = appleRepository
    }
    
    func appleLogin(authUserData: AuthUserData) async -> UserState {
        return await appleRepository.login(authUserData: authUserData)
    }
    
    func appleLogout() async {
        await appleRepository.logout()
    }
}
