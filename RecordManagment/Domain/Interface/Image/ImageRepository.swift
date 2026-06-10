import Foundation

/// 이미지 관련 인터페이스입니다.
protocol ImageRepository: Sendable {
    func fetch(_ url: URL) async throws(ImageRepositoryError) -> Data
    func upload(files: [Data?]) async throws(ImageRepositoryError) -> [String]
}
