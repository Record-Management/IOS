import SwiftUI

final class RouterUseCase {
    let repository: RouterRepository
    
    init(repository: RouterRepository) {
        self.repository = repository
    }
    
    func autoLogin(completion: () -> Void) async -> UserState {
        return await repository.refreshLogin(completion: completion)
    }
    
    func autoLogout() async {
        await repository.logout()
    }
}
