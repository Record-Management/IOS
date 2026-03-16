import Foundation
import Alamofire

struct DefaultSettingRepository: SettingRepository {
    private let intergrationManager: IntergrationManager
    
    init(intergrationManager: IntergrationManager = .shared) {
        self.intergrationManager = intergrationManager
    }
    
    func updateProfile(form: [String : Any]) async throws -> Result<User, LoginError> {
        guard let domain = await intergrationManager.manager.domain, let url = URL(string: "\(domain)/api/users/profile") else {
            throw URLError(.badURL)
        }

        let result = await intergrationManager.withTokenRetry {
            guard let accessToken = await intergrationManager.manager.keyChain.read(account: "accessToken") else {
                throw LoginError.notToken
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            
            return try await AF.request(
                url,
                method: .put,
                parameters: form,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .serializingDecodable(User.self)
            .value
        }
        
        return result
    }


    func initStateNotificationSetting() async -> Result<NotificationSettingDTO, LoginError> {
        guard let domain = await intergrationManager.manager.domain, let url = URL(string: "\(domain)/api/notifications/settings") else {
            return .failure(.networkError(.invalidURL(url: "/api/notifications/settings")))
        }

        let result = await intergrationManager.withTokenRetry {
            guard let accessToken = await intergrationManager.manager.keyChain.read(account: "accessToken") else {
                throw LoginError.notToken
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            
            return try await AF.request(
                url,
                method: .get,
                headers: headers
            )
            .serializingDecodable(NotificationSettingDTO.self)
            .value
        }
        
        return result
    }
    
    func notificationRecordUpdate(data: NotificationSettingRequestBody) async -> Result<NotificationSettingDTO, LoginError> {
        guard let domain = await intergrationManager.manager.domain, let url = URL(string: "\(domain)/api/notifications/settings") else {
            return .failure(.networkError(.invalidURL(url: "/api/notifications/settings")))
        }

        let result = await intergrationManager.withTokenRetry {
            guard let accessToken = await intergrationManager.manager.keyChain.read(account: "accessToken") else {
                throw LoginError.notToken
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            
            return try await AF.request(
                url,
                method: .put,
                parameters: data,
                encoder: JSONParameterEncoder.default,
                headers: headers
            )
            .serializingDecodable(NotificationSettingDTO.self)
            .value
        }
        
        return result
    }
    
    func resetGoal() async throws {
        guard let domain = await intergrationManager.manager.domain,
              let url = URL(string: "\(domain)/api/goals/current/force-complete") else {
            throw LoginError.networkError(.invalidURL(url: "/api/goals/current/force-complete"))
        }

        let result = await intergrationManager.withTokenRetry {
            guard let accessToken = await intergrationManager.manager.keyChain.read(account: "accessToken") else {
                throw LoginError.notToken
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            
            _ = try await AF.request(
                url,
                method: .patch,
                headers: headers
            )
            .serializingData()
            .value
            
            return true
        }

        if case .failure(let error) = result {
            throw error
        }
    }
}
