import Foundation

class HabitRecordUseCase {
    private let repository: HabitRecordRepository
    
    init(repository: HabitRecordRepository) {
        self.repository = repository
    }
    
    func create(request: HabitRequestBody) async -> Result<HabitDTO, LoginError> {
        await repository.createHabitRecord(form: request)
    }
    
    func update(form: HabitRequestBody, recordId: String) async -> Result<HabitDTO, LoginError> {
        await repository.updateHabitRecord(form: form, recordId: recordId)
    }
    
    func delete(recordId: String) async -> Result<HabitDTO, LoginError> {
        await repository.deleteHabitRecord(recordId: recordId)
    }
}
