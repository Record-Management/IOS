import Foundation
import Alamofire

class DefaultRouterRepository: RouterRepository {
    let manager: LoginNetworkManager = .init()
    let common: IntergrationManager = .shared
    
    func refreshLogin(completion: () -> Void) async -> UserState {
        return await manager.autoLogin(completion: completion)
    }
    
    func logout() async -> Bool {
        return await manager.logout()
    }
    
    func withdraw() async -> Bool {
        return await manager.WithdrawMembership()
    }
}

extension DefaultRouterRepository {
    func fetchReport(id: String) async -> Result<GoalAchieve, LoginError> {
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/goals/achievement/report") else {
            return .failure(.networkError(.invalidURL(url: "/api/goals/achievement/report")))
        }
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "userId" : id
        ]
        
        let task = AF.request(
            url,
            method: .get,
            headers: headers
        )
        
        let result = await common.withTokenRetry {
            let response = try await task.serializingDecodable(GoalAchieve.self).value
            return response
        }
        
        return result
    }
}
