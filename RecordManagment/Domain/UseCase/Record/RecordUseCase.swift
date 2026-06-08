import Foundation



protocol RecordUseCase {
    func fetchRecords(_ date: Date) async throws -> ([IntergrationRecord], [ScheduleDetail])
    func dailyPerform(
        method: RecordMethod,
        selectedImages: [PhotoTransfer],
        makeForm: @MainActor ([String]) -> DailyFormat,
        create: (DailyFormat) async -> Result<DailyDTO, LoginError>,
        update: (DailyFormat) async -> Result<DailyDTO, LoginError>
    ) async -> Result<DailyDTO, LoginError>
    func exercisePerform(
        method: RecordMethod,
        selectedImages: [PhotoTransfer],
        makeForm: @MainActor ([String]) -> ExerciseBody,
        create: (ExerciseBody) async -> Result<ExerciseDTO, LoginError>,
        update: (ExerciseBody) async -> Result<ExerciseDTO, LoginError>
    ) async -> Result<ExerciseDTO, LoginError>
    func dailyDelete(_ id: String) async -> Result<DailyDTO, LoginError>
    func exerciseDelete(_ id: String) async -> Result<ExerciseDTO, LoginError>
    func habitDelete(_ id: String) async -> Result<HabitDTO, LoginError>
}

struct DefaultRecordUseCase: RecordUseCase {
    private let calendarRepository: CalendarRepository
    
    init(calendarRepository: CalendarRepository) {
        self.calendarRepository = calendarRepository
    }
    
    func fetchRecords(_ date: Date) async throws -> ([IntergrationRecord], [ScheduleDetail]) {
        do {
            return try await calendarRepository.fetchDateDetailRecords(for: date)
        } catch {
            return ([], [])
        }
    }
    
    func dailyPerform(
        method: RecordMethod,
        selectedImages: [PhotoTransfer],
        makeForm: @MainActor ([String]) -> DailyFormat,
        create: (DailyFormat) async -> Result<DailyDTO, LoginError>,
        update: (DailyFormat) async -> Result<DailyDTO, LoginError>
    ) async -> Result<DailyDTO, LoginError> {
        let form = await makeForm([])
        if method == .create {
            return await create(form)
        } else {
            return await update(form)
        }
    }
    
    func exercisePerform(
        method: RecordMethod,
        selectedImages: [PhotoTransfer],
        makeForm: @MainActor ([String]) -> ExerciseBody,
        create: (ExerciseBody) async -> Result<ExerciseDTO, LoginError>,
        update: (ExerciseBody) async -> Result<ExerciseDTO, LoginError>
    ) async -> Result<ExerciseDTO, LoginError> {
        let form = await makeForm([])
        if method == .create {
            return await create(form)
        } else {
            return await update(form)
        }
    }
    
    func dailyDelete(_ id: String) async -> Result<DailyDTO, LoginError> {
        return .success(DailyDTO(statusCode: 200, code: "SUCCESS", message: "Deleted", data: nil))
    }
    
    func exerciseDelete(_ id: String) async -> Result<ExerciseDTO, LoginError> {
        return .success(ExerciseDTO(code: "SUCCESS", statusCode: 200, message: "Deleted", data: nil))
    }
    
    func habitDelete(_ id: String) async -> Result<HabitDTO, LoginError> {
        return .success(HabitDTO(statusCode: 200, code: "SUCCESS", message: "Deleted", data: nil))
    }
}
