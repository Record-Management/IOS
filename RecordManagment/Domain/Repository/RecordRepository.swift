import Foundation

protocol RecordRepository {
    func updateRecords(_ date: Date) async throws -> [IntergrationRecord]

    func submit<T, V>(
        method: RecordMethod,
        selectedImages: [PhotoTransfer],
        makeForm: @MainActor (_ imageUrls: [String]) -> T,
        create: (T) async -> Result<V, LoginError>,
        update: (T) async -> Result<V, LoginError>
    ) async -> Result<V, LoginError>
}
