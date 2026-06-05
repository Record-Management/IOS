import UserNotifications
import UIKit
import FirebaseCore
import Alamofire

enum UserDefaultKey {
    static let didAskNotificationPermission = "didAskNotificationPermission"
}

final class NotificationService: NSObject {
    static let shared = NotificationService(manager: .shared)
    private let manager: IntergrationManager
    var token: String?
    init(manager: IntergrationManager) {
        self.manager = manager
    }
    
    let center = UNUserNotificationCenter.current()
    
    // 알림 권한 요청
    func requestNotificationPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .badge, .sound]) { grant, err in
                if let err = err {
                    debugPrint("알림 권한 요청 실패 : \(err.localizedDescription)")
                }
                
                if !grant {
                    UserDefaults.standard.set(true, forKey: UserDefaultKey.didAskNotificationPermission)
                }
                continuation.resume(returning: grant)
            }
        }
    }
    
    // 알림 권한 상태 확인 (상세한 상태 반환)
    func getNotificationAuthorizationStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }
}

// MARK: Firebase Notification Delegate Extension
extension NotificationService: UNUserNotificationCenterDelegate {
    
    // Push Notification Present Method
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        debugPrint("Present userInfo : \(userInfo)")
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        debugPrint("Receive userInfo : \(userInfo)")
        completionHandler()
    }
}


// MARK: FCM Token 서버 넘기는 Extension
extension NotificationService {
    func fcmTokenReqeust() async throws(LoginError) {
        guard let token else { throw LoginError.notToken } // fcm Token is Not
        let urlString: String = "\(manager.domain)/api/users/fcm-token"
        guard let url = URL(string: urlString)
        else { throw .invaildURL(urlString) }
        
        guard let accessToken = await manager.keyChain.read(account: "accessToken") else {
            throw LoginError.notToken
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let parameters: Parameters = [
            "fcmToken" : token
        ]
        
        debugPrint("token : \(token)")
                
        let task = AF.request(
            url,
            method: .put,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(User.self).value
                return response
            }
        } catch {
            Log.error(error.localizedDescription)
            throw .unknown(error)
        }
    }
}
