import Foundation

struct DefaultRecordRepository: RecordRepository {
    private let manager: RecordNetworkManager
    
    init(manager: RecordNetworkManager = .init()) {
        self.manager = manager
    }
    
    func updateRecords(_ date: Date) async throws -> [IntergrationRecord] {
        try await manager.fetchDateForDetailRecords(for: date)
    }
    
    func submit<T, V>(method: RecordMethod, selectedImages: [PhotoTransfer], makeForm: @MainActor ([String]) -> T, create: (T) async -> Result<V, LoginError>, update: (T) async -> Result<V, LoginError>) async -> Result<V, LoginError> {
        let result = await manager.submitRecord(
            method: method,
            selectedImages: selectedImages,
            makeForm: makeForm,
            create: create,
            update: update
        )
        
        if case .success = result {
            AppReviewManager.shared.markRecordCreated()
        }
        
        return result
    }
    
    func delete<T: Decodable>(recordId: String, type: String) async -> Result<T, LoginError> {
        await manager.deleteRecord(recordId: recordId, type: type)
    }
}
