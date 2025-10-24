//
//  AppNoticeView.swift
//  RecordManagment
//
//  Created by 김용해 on 10/22/25.
//

import SwiftUI

struct AppNoticeView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var isOn: Bool = false
    
    var body: some View {
        VStack {
            RecordListTile(title: "목표 미설정 알림", subline: "목표 기록 미설정 시 알림", isOn: $isOn)
            Spacer()
        }
        .padding()
        .seedsDayNavigationStyle(title: "") {
            coordinator.pop()
        }
        .task {
            isOn = await NotificationService.shared.requestNotificationPermission()
            if isOn { // 알림이 허용 되어 있다면 서버에 FCM Token 전송
                do {
                    let success = try await NotificationService.shared.fcmTokenReqeust()
                    debugPrint(success)
                } catch {
                    debugPrint("fcm 서버 전송 Error : \(error)")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppNoticeView()
    }
}
