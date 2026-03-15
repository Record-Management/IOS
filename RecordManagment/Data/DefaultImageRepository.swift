import Foundation

struct DefaultImageRepository: ImageRepository {
    private let manager: FetchFileManager
    
    init(manager: FetchFileManager = .init()) {
        self.manager = manager
    }
    
    func fetch(_ url: URL) async -> Data {
        await manager.fetchImage(url: url)
    }
}
