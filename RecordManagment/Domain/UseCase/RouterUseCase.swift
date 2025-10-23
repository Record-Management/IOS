import SwiftUI

final class RouterUseCase {
    let repository: RouterRepository
    
    init(repository: RouterRepository) {
        self.repository = repository
    }
    
    func autoLogin(completion: () -> Void) async -> UserState {
        return await repository.refreshLogin(completion: completion)
    }
    
    func logout() async -> Bool {
        return await repository.logout()
    }
    
    func withdraw() async -> Bool {
        return await repository.withdraw()
    }
}
