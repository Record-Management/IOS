import Foundation

class DefaultRecordRepository: RecordRepository {
    let manager: RecordNetworkManager = .init()
    
    func updateRecords(_ date: Date) async throws -> [IntergrationRecord] {
        try await manager.fetchDateForDetailRecords(for: date)
    }
    
    func submit<T, V>(method: RecordMethod, selectedImages: [PhotoTransfer], makeForm: @MainActor ([String]) -> T, create: (T) async -> Result<V, LoginError>, update: (T) async -> Result<V, LoginError>) async -> Result<V, LoginError> {
        await manager.submitRecord(
            method: method,
            selectedImages: selectedImages,
            makeForm: makeForm,
            create: create,
            update: update
        )
    }
}
