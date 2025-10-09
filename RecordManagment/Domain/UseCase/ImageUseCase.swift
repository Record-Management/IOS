import Foundation

class ImageUseCase {
    private let repository: ImageRepository
    
    init(repository: ImageRepository) {
        self.repository = repository
    }
    
    func getImage(_ url: URL) async -> Data {
        await repository.fetch(url)
    }
}
