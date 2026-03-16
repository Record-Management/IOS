import SwiftUI

protocol RouterUseCase {
    func autoLogin(completion: () -> Void) async -> UserState
    func logout() async -> Bool
    func withdraw() async -> Bool
    func achive(userId: String) async throws -> GoalAchieve
}

struct DefaultRouterUseCase: RouterUseCase {
    private let repository: RouterRepository
    
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
    
    func achive(userId: String) async throws -> GoalAchieve {
        let result = await repository.fetchReport(id: userId)
        
        switch result {
        case .success(let res):
            return res
        case .failure(let failure):
            throw failure
        }
    }
}

