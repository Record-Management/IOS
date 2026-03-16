import Foundation

struct DefaultUserRepository: UserRepository {
    private let intergrationManager: IntergrationManager
    
    init(intergrationManager: IntergrationManager = .shared) {
        self.intergrationManager = intergrationManager
    }
    
    func fetchMyInfo() async throws -> Result<User, LoginError> {
        guard let domain = await intergrationManager.manager.domain, let url = URL(string: "\(domain)/api/users/me") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        guard let accessToken = await intergrationManager.manager.keyChain.read(account: "accessToken") else { throw URLError(.badURL) }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let user = await intergrationManager.withTokenRetry {
            let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
            let decode = try JSONDecoder().decode(User.self, from: data)
            
            return decode
        }
        
        return user
    }
}
