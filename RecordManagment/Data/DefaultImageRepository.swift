import Foundation

class DefaultImageRepository: ImageRepository {
    let manager: FetchFileManager = .init()
    
    func fetch(_ url: URL) async -> Data {
        await manager.fetchImage(url: url)
    }
}
