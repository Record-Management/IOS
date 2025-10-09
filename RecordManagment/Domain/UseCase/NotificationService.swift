//
//  NotificationService.swift
//  RecordManagment
//
//  Created by 김용해 on 9/3/25.
//

import UserNotifications
import UIKit

enum UserDefaultKey {
    static let didAskNotificationPermission = "didAskNotificationPermission"
}

class NotificationService {
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
