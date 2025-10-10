import Foundation

class DefaultRecordRepository: RecordRepository {
    let manager: RecordNetworkManager = .init()
    
    func updateRecords(_ date: Date) async throws -> [IntergrationRecord] {
        try await manager.fetchDateForDetailRecords(for: date)
    }
    
    func submit<T, V>(isEditing: Bool, selectedImages: [PhotoTransfer], makeForm: @MainActor ([String]) -> T, create: (T) async -> Result<V, LoginError>, update: (T) async -> Result<V, LoginError>) async -> Result<V, LoginError> {
        await manager.submitRecord(
            isEditing: isEditing,
            selectedImages: selectedImages,
            makeForm: makeForm,
            create: create,
            update: update
        )
    }
}
