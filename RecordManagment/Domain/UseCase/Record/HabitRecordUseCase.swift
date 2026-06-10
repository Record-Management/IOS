import Foundation

protocol HabitRecordUseCase {
    func create(request: HabitRequestBody) async -> Result<HabitDTO, LoginError>
    func update(form: HabitRequestBody, recordId: String) async -> Result<HabitDTO, LoginError>
    func delete(recordId: String) async -> Result<HabitDTO, LoginError>
}

struct DefaultHabitRecordUseCase: HabitRecordUseCase {
    private let repository: any HabitRepository
    
    init(repository: any HabitRepository) {
        self.repository = repository
    }
    
    func create(request: HabitRequestBody) async -> Result<HabitDTO, LoginError> {
        do {
            let result = try await repository.create(form: request)
            return .success(result)
        } catch {
            return .failure(.loginFailed)
        }
    }
    
    func update(form: HabitRequestBody, recordId: String) async -> Result<HabitDTO, LoginError> {
        do {
            let result = try await repository.update(recordId: recordId, form: form)
            return .success(result)
        } catch {
            return .failure(.loginFailed)
        }
    }
    
    func delete(recordId: String) async -> Result<HabitDTO, LoginError> {
        do {
            let result = try await repository.delete(recordId: recordId)
            return .success(result)
        } catch {
            return .failure(.loginFailed)
        }
    }
}

