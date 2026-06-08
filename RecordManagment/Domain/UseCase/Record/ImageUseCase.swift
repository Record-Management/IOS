import Foundation

protocol ImageUseCase {
    func getImage(_ url: URL) async -> Data
}

struct DefaultImageUseCase: ImageUseCase {
    private let repository: ImageRepository
    
    init(repository: ImageRepository) {
        self.repository = repository
    }
    
    func getImage(_ url: URL) async -> Data {
        do {
            return try await repository.fetch(url)
        } catch {
            Log.error("Image fetch failed: \(error.localizedDescription)")
            return Data()
        }
    }
}

