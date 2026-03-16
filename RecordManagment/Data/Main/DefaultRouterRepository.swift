import Foundation
import Alamofire

struct DefaultRouterRepository: RouterRepository {
    private let loginManager: LoginNetworkManager
    private let intergrationManager: IntergrationManager
    
    init(loginManager: LoginNetworkManager = .init(), intergrationManager: IntergrationManager = .shared) {
        self.loginManager = loginManager
        self.intergrationManager = intergrationManager
    }
    
    func refreshLogin(completion: () -> Void) async -> UserState {
        return await loginManager.autoLogin(completion: completion)
    }
    
    func logout() async -> Bool {
        return await loginManager.logout()
    }
    
    func withdraw() async -> Bool {
        return await loginManager.WithdrawMembership()
    }
}

extension DefaultRouterRepository {
    func fetchReport(id: String) async -> Result<GoalAchieve, LoginError> {
        guard let domain = await intergrationManager.manager.domain, let url = URL(string: "\(domain)/api/goals/achievement/report") else {
            return .failure(.networkError(.invalidURL(url: "/api/goals/achievement/report")))
        }

        let result = await intergrationManager.withTokenRetry {
            guard let accessToken = await intergrationManager.manager.keyChain.read(account: "accessToken") else {
                throw LoginError.notToken
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken)",
                "userId" : id
            ]
            
            return try await AF.request(
                url,
                method: .get,
                headers: headers
            )
            .serializingDecodable(GoalAchieve.self)
            .value
        }
        
        return result
    }
}
