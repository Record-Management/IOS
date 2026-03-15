import Foundation

protocol SettingUseCase {
    func update(with form: [String: Any]) async throws -> User
    func fetch(data: NotificationSettingRequestBody) async -> Bool
    func check() async throws -> NotificationSettingData
    func reset() async throws
}

struct DefaultSettingUseCase: SettingUseCase {
    private let repository: SettingRepository
    
    init(repository: SettingRepository) {
        self.repository = repository
    }
    
    func update(with form: [String: Any]) async throws -> User {
        let result = try await repository.updateProfile(form: form)
        
        switch result {
        case .success(let success):
            return success
        case .failure(let err):
            throw err
        }
    }
    
    func fetch(data: NotificationSettingRequestBody) async -> Bool {
        let result = await repository.notificationRecordUpdate(data: data)
        
        switch result {
            case .success(_):
                return true
            case .failure(let err):
                debugPrint("기록 알림 업데이트 err : \(err)")
                return false
        }
    }
    
    func check() async throws -> NotificationSettingData {
        let result = await repository.initStateNotificationSetting()
        
        switch result {
            case .success(let res):
                if let data = res.data {
                    return data
                }
                throw URLError(.cannotDecodeContentData)
            case .failure(let failure):
                throw failure
        }
    }
    
    func reset() async throws {
        try await repository.resetGoal()
    }
}

