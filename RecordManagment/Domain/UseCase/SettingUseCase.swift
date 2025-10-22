import Foundation

class SettingUseCase {
    private let repository: SettingRepository
    
    init(repository: SettingRepository) {
        self.repository = repository
    }
    
    func update(with form: [String: Any]) async throws -> User {
        do {
            let result = try await repository.updateProfile(form: form)
            
            switch result {
                case .success(let success):
                    return success
                case .failure(let err):
                    throw err
            }
        } catch {
            throw error
        }
    }
}
