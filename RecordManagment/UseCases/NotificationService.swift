//
//  NotificationService.swift
//  RecordManagment
//
//  Created by 김용해 on 9/3/25.
//

import UserNotifications

class NotificationService {
    let center = UNUserNotificationCenter.current()
    
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
}
