//
//  AppNoticeView.swift
//  RecordManagment
//
//  Created by 김용해 on 10/22/25.
//

import SwiftUI

struct RecordNoticeView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var totalRecordIsOn: Bool = false
    @State private var dailyIsOn: Bool = false
    @State private var exerciseIsOn: Bool = false
    @State private var habitIsOn: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            RecordListTile(title: "기록 전체 알림", isOn: $totalRecordIsOn)
            Divider()
            RecordListTile(title: "하루 기록", subline: "메인 기록에 대한 미기록 알림", isOn: $dailyIsOn)
            RecordListTile(title: "운동 기록", subline: "메인 기록에 대한 미기록 알림", isOn: $exerciseIsOn)
            RecordListTile(title: "습관 기록", subline: "메인 기록에 대한 등록 시간 알림", isOn: $habitIsOn)
            Spacer()
        }
        .padding()
        .seedsDayNavigationStyle(title: "") {
            coordinator.pop()
        }
    }
}

#Preview {
    NavigationStack {
        AppNoticeView()
    }
}
