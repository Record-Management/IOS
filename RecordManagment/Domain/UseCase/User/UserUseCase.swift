import Foundation

protocol UserUseCase {
    func getUserData() async throws -> Result<User, LoginError>
}

struct DefaultUserUseCase: UserUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func getUserData() async throws -> Result<User, LoginError> {
        do {
            let user = try await repository.fetchMyInfo()
            return .success(user)
        } catch {
            return .failure(.loginFailed)
        }
    }
}

