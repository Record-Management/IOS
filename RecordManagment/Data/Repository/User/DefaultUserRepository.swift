import Foundation

struct DefaultUserRepository: UserRepository {
    private let intergrationManager: IntergrationManager
    
    init(intergrationManager: IntergrationManager = .shared) {
        self.intergrationManager = intergrationManager
    }
    
    func fetchMyInfo() async throws -> Result<User, LoginError> {
        let domain = intergrationManager.domain
        guard let url = URL(string: "\(domain)/api/users/me") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        guard let accessToken = await intergrationManager.keyChain.read(account: "accessToken") else { throw URLError(.badURL) }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let user = try await intergrationManager.withTokenRetry {
                let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
                let decode = try JSONDecoder().decode(User.self, from: data)
                
                return decode
            }
            return .success(user)
        } catch {
            return .failure(error)
        }
    }
}
