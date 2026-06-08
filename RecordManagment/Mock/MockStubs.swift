import Foundation

// MARK: - Dummy DefaultRecordRepository
struct DefaultRecordRepository: RecordRepository {
    typealias RequestType = DailyFormat
    typealias ResponseType = DailyDTO
    
    func create(form: DailyFormat, type: String) async throws(RecordRepositoryError) -> DailyDTO {
        return DailyDTO(statusCode: 200, code: "SUCCESS", message: "", data: nil)
    }
    
    func update(recordId: String, form: DailyFormat, type: String) async throws(RecordRepositoryError) -> DailyDTO {
        return DailyDTO(statusCode: 200, code: "SUCCESS", message: "", data: nil)
    }
    
    func delete(recordId: String, type: String) async throws(RecordRepositoryError) -> DailyDTO {
        return DailyDTO(statusCode: 200, code: "SUCCESS", message: "", data: nil)
    }
}

// MARK: - Default Initializer Extensions for Repositories and UseCases
extension DefaultRecordUseCase {
    init(repository: any RecordRepository) {
        self.init(calendarRepository: DefaultCalendarRepository(manager: .shared, keyChain: .shared))
    }
}

extension DefaultImageUseCase {
    init() {
        self.init(repository: DefaultImageRepository(manager: .shared))
    }
}

extension DefaultImageRepository {
    init() {
        self.init(manager: .shared)
    }
}

extension DefaultCalendarRepository {
    init() {
        self.init(manager: .shared, keyChain: .shared)
    }
}

extension DefaultHabitRecordRepository {
    init() {
        self.init(manager: .shared)
    }
}

extension DefaultDailyRecordRepository {
    init() {
        self.init(manager: .shared)
    }
}

extension DefaultExerciseRecordRepository {
    init() {
        self.init(manager: .shared)
    }
}
