import Foundation

protocol ImageRepository {
    func fetch(_ url: URL) async -> Data
}
