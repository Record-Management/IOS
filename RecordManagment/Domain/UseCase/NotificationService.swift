import UserNotifications
import UIKit
import FirebaseCore
import Alamofire

enum UserDefaultKey {
    static let didAskNotificationPermission = "didAskNotificationPermission"
}

class NotificationService: NSObject {
    static let shared: NotificationService = .init()
    let common: IntergrationManager = .shared
    var token: String?
    private override init() {}
    
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

    // 앱 설정 화면으로 이동하는 함수
    @MainActor
    func openAppSettings() async {
        await withCheckedContinuation { continuation in
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) else {
                debugPrint("설정 화면을 열 수 없습니다.")
                return
            }
            UIApplication.shared.open(url)
            continuation.resume()
        }
    }
}

// MARK: Firebase Notification Delegate Extension
extension NotificationService: UNUserNotificationCenterDelegate {
    
    // Push Notification Present Method
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Present userInfo : \(userInfo)")
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Receive userInfo : \(userInfo)")
        completionHandler()
    }
}


// MARK: FCM Token 서버 넘기는 Extension
extension NotificationService {
    func fcmTokenReqeust() async throws -> Bool {
        guard let token else { throw LoginError.notToken } // fcm Token is Not
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/users/fcm-token") else { throw URLError(.badURL)}
        
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
            throw LoginError.notToken
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let parameters: Parameters = [
            "fcmToken" : token
        ]
        
        let task = AF.request(
            url,
            method: .patch,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        
        let result = await common.withTokenRetry {
            let response = try await task.serializingDecodable(User.self).value
            return response
        }
        
        switch result {
            case .success(_):
                return true
            case .failure(_):
                return false
        }
    }
}
