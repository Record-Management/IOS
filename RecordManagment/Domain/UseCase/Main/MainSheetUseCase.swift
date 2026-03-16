import Foundation

protocol MainSheetUseCase {
    @discardableResult
    func fetch(_ isCompleted: Bool, recordId id: String) async throws -> Bool
}

struct DefaultMainSheetUseCase: MainSheetUseCase {
    private let repository: MainSheetRepository
    
    init(repository: MainSheetRepository) {
        self.repository = repository
    }
    
    @discardableResult
    func fetch(_ isCompleted: Bool, recordId id: String) async throws -> Bool {
        let result = await repository.fetchCompletionHabit(isCompleted, recordId: id)
        
        switch result {
        case .success(let res):
            if let completion = res.data?.isCompleted {
                return completion
            }
            throw LoginError.serverError
        case .failure(let err):
            debugPrint("fetch err: \(err)")
            throw err
        }
    }
}

