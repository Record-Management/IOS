import Foundation
import Alamofire

class DefaultSettingRepository: SettingRepository {
    let common: IntergrationManager = .shared
    
    func updateProfile(form: [String : Any]) async throws -> Result<User, LoginError> {
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/users/profile") else {
            throw URLError(.badURL)
        }
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let parameters: Parameters = form
        
        let task = AF.request(
            url,
            method: .put,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        
        let result = await common.withTokenRetry {
            let response = try await task.serializingDecodable(User.self).value
            return response
        }
        
        return result
    }


    func initStateNotificationSetting() async -> Result<NotificationSettingDTO, LoginError> {
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/notifications/settings") else {
            return .failure(.networkError(.invalidURL(url: "/api/notifications/settings")))
        }
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .get,
            headers: headers
        )
        
        let result = await common.withTokenRetry {
            let response = try await task.serializingDecodable(NotificationSettingDTO.self).value
            return response
        }
        
        return result
    }
    
    func notificationRecordUpdate(data: NotificationSettingRequestBody) async -> Result<NotificationSettingDTO, LoginError> {
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/notifications/settings") else {
            return .failure(.networkError(.invalidURL(url: "/api/notifications/settings")))
        }
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .put,
            parameters: data,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
        
        let result = await common.withTokenRetry {
            let response = try await task.serializingDecodable(NotificationSettingDTO.self).value
            return response
        }
        
        return result
    }
}
