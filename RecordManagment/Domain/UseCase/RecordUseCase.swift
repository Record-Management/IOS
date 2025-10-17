import Foundation

class RecordUseCase {
    private let repository: RecordRepository
    
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    func fetchRecords(_ date: Date) async throws -> [IntergrationRecord] {
        return try await repository.updateRecords(date)
    }
    
    // TODO: 하루 기록
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
    
    // TODO: 운동 기록
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
    
    // TODO: 하루 기록 삭제
    func dailyDelete(_ id: String) async -> Result<DailyDTO, LoginError> {
        await repository.delete(recordId: id, type: "daily")
    }
    
    // TODO: 운동 기록 삭제
    func exerciseDelete(_ id: String) async -> Result<ExerciseDTO, LoginError> {
        await repository.delete(recordId: id, type: "exercise")
    }
    
    func habitDelete(_ id: String) async -> Result<HabitDTO, LoginError> {
        await repository.delete(recordId: id, type: "habit")
    }
}
