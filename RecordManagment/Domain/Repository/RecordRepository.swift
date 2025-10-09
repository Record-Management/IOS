import Foundation

protocol RecordRepository {
    func updateRecords(_ date: Date) async throws -> [IntergrationRecord]

    func submit<T, V>(
        isEditing: Bool,
        selectedImages: [PhotoTransfer],
        makeForm: (_ imageUrls: [String]) -> T,
        create: (T) async -> Result<V, LoginError>,
        update: (T) async -> Result<V, LoginError>
    ) async -> Result<V, LoginError>
}
