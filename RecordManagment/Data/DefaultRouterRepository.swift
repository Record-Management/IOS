import Foundation

class DefaultRouterRepository: RouterRepository {
    let manager: LoginNetworkManager = .init()
    
    func refreshLogin(completion: () -> Void) async -> UserState {
        return await manager.autoLogin(completion: completion)
    }
    
    func logout() async {
        await manager.logout()
    }
}
