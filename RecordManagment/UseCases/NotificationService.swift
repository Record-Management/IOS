//
//  NotificationService.swift
//  RecordManagment
//
//  Created by 김용해 on 9/3/25.
//

import UserNotifications

class NotificationService {
    let center = UNUserNotificationCenter.current()
    
    // 알림 권한 요청
    func requestNotificationPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .badge, .sound]) { grant, err in
                if let err = err {
                    debugPrint("알림 권한 요청 실패 : \(err.localizedDescription)")
                }
                continuation.resume(returning: grant)
            }
        }
    }
    
    // 알림 권한 확인
    func checkNotificationAuthorizationStatus() async -> Bool {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    continuation.resume(returning: true)
                default:
                    continuation.resume(returning: false)
                }
            }
        }
    }
}
