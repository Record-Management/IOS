import Foundation

class RecordUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func getUserData() async throws -> Result<User, LoginError> {
        try await repository.fetchMyInfo()
    }
}
