import Foundation

class RecordUseCase {
    private let repository: RecordRepository
    
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    func fetchRecords(_ date: Date) async throws -> [IntergrationRecord] {
        return try await repository.updateRecords(date)
    }
    
    func dailyPerform(
        method: RecordMethod,
        selectedImages: [PhotoTransfer],
        makeForm: @MainActor ([String]) -> DailyFormat,
        create: (DailyFormat) async -> Result<DailyDTO, LoginError>,
        update: (DailyFormat) async -> Result<DailyDTO, LoginError>
    ) async -> Result<DailyDTO, LoginError> {
        await repository.submit(
            method: method,
            selectedImages: selectedImages,
            makeForm: makeForm,
            create: create,
            update: update)
    }
    
    func exercisePerform(
        method: RecordMethod,
        selectedImages: [PhotoTransfer],
        makeForm: @MainActor ([String]) -> ExerciseBody,
        create: (ExerciseBody) async -> Result<ExerciseDTO, LoginError>,
        update: (ExerciseBody) async -> Result<ExerciseDTO, LoginError>
    ) async -> Result<ExerciseDTO, LoginError> {
        await repository.submit(
            method: method,
            selectedImages: selectedImages,
            makeForm: makeForm,
            create: create,
            update: update)
    }
}
