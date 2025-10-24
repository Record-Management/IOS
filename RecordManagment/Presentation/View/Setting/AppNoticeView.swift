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
        }
    }
}

#Preview {
    NavigationStack {
        AppNoticeView()
    }
}
