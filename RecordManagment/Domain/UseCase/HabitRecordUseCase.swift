import Foundation

class HabitRecordUseCase {
    private let repository: HabitRecordRepository
    
    init(repository: HabitRecordRepository) {
        self.repository = repository
    }
    
    func create(request: HabitRequestBody) async -> Result<HabitDTO, LoginError> {
        await repository.createHabitRecord(form: request)
    }
}
