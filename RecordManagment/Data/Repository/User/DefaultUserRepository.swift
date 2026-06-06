import Foundation
import Alamofire

/// 사용자 정보 조회 및 프로필 업데이트 기능을 처리하는 레포지토리 구현체입니다.
struct DefaultUserRepository: UserRepository {
    private let manager: IntergrationManager
    private let keyChain: KeyChainManager = .shared
    
    init(manager: IntergrationManager = .shared) {
        self.manager = manager
    }
    
    /// 현재 로그인한 내 정보를 조회합니다.
    func fetchMyInfo() async throws(UserRepositoryError) -> User {
        let url = DomainManager.Path.usersMe.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.usersMe.urlString)
        }
        var request = URLRequest(url: url)
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let user = try await manager.withTokenRetry {
                let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
                let decode = try JSONDecoder().decode(User.self, from: data)
                return decode
            }
            return user
        } catch {
            Log.error(error.localizedDescription)
            throw .fetchMyInfoFailed
        }
    }
    
    /// 내 프로필 정보를 수정합니다.
    func updateProfile(form: [String : Any]) async throws(UserRepositoryError) -> User {
        let url = DomainManager.Path.usersProfile.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.usersProfile.urlString)
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .put,
            parameters: form,
            encoding: JSONEncoding.default,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(User.self).value
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .profileUpdateFailed
        }
    }
}
