import Foundation
import Alamofire

/// 알림 내역 조회 및 알림 설정 변경 기능을 처리하는 레포지토리 구현체입니다.
struct DefaultNotificationRepository: NotificationRepository {
    private let manager: IntergrationManager
    private let keyChain: KeyChainManager = .shared
    
    init(manager: IntergrationManager = .shared) {
        self.manager = manager
    }
    
    /// 유저의 수신된 알림 내역 목록을 조회합니다.
    func fetchNotifications() async throws(NotificationRepositoryError) -> NotificationDTO {
        let url = DomainManager.Path.notificationsHistory.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.notificationsHistory.urlString)
        }
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .get,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(NotificationDTO.self).value
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .notificationFetchFailed
        }
    }
    
    /// 수신된 알림 내역을 읽음 처리합니다.
    func updateNotification() async throws(NotificationRepositoryError) {
        let url = DomainManager.Path.readNotificationHistory.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.notificationsSettings.urlString)
        }

        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .put,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = task.serializingData()
                return response
            }
        } catch {
            Log.error(error.localizedDescription)
            throw .notificationReadFailed
        }
    }
    
    /// 알림 수신 상태 동기화 및 설정을 업데이트합니다.
    func notificationRecordUpdate(data: NotificationSettingRequestBody) async throws(NotificationRepositoryError) -> NotificationSettingDTO {
        let url = DomainManager.Path.notificationsSettings.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.notificationsSettings.urlString)
        }

        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .put,
            parameters: data,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(NotificationSettingDTO.self).value
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .notificationUpdateFailed
        }
    }
    
    /// 초기 알림 수신 동기화 정보(첫 진입 시 디폴트 설정 조회용)를 요청합니다.
    func initStateNotificationSetting() async throws(NotificationRepositoryError) -> NotificationSettingDTO {
        let url = DomainManager.Path.notificationsSettings.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.notificationsSettings.urlString)
        }

        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .get,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(NotificationSettingDTO.self).value
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .notificationInitFailed
        }
    }
}
