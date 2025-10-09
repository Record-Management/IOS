import Foundation

final class DefaultUserRepository: UserRepository {
    let common: IntergrationManager = .shared
    
    func fetchMyInfo() async throws -> Result<User, LoginError> {
        let domain = await common.manager.domain
        guard let url = URL(string: "\(domain ?? "domain")/api/users/me") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else { throw URLError(.badURL) }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let user = await common.withTokenRetry {
            let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
            let decode = try JSONDecoder().decode(User.self, from: data)
            
            return decode
        }
        
        return user
    }
}
