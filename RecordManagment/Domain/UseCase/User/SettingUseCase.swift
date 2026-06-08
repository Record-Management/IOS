import Foundation

protocol SettingUseCase {
    func update(with form: [String: Any]) async throws -> User
    func fetch(data: NotificationSettingRequestBody) async -> Bool
    func check() async throws -> NotificationSettingData
    func reset() async throws
}

struct DefaultSettingUseCase: SettingUseCase {
    private let userRepository: UserRepository
    private let goalRepository: GoalRepository
    private let notificationRepository: NotificationRepository
    
    init(
        userRepository: UserRepository,
        goalRepository: GoalRepository,
        notificationRepository: NotificationRepository
    ) {
        self.userRepository = userRepository
        self.goalRepository = goalRepository
        self.notificationRepository = notificationRepository
    }
    
    func update(with form: [String: Any]) async throws -> User {
        return try await userRepository.updateProfile(form: form)
    }
    
    func fetch(data: NotificationSettingRequestBody) async -> Bool {
        do {
            _ = try await notificationRepository.notificationRecordUpdate(data: data)
            return true
        } catch {
            debugPrint("기록 알림 업데이트 err : \(error)")
            return false
        }
    }
    
    func check() async throws -> NotificationSettingData {
        do {
            let res = try await notificationRepository.initStateNotificationSetting()
            if let data = res.data {
                return data
            }
            throw URLError(.cannotDecodeContentData)
        } catch {
            throw error
        }
    }
    
    func reset() async throws {
        try await goalRepository.resetGoal()
    }
}

