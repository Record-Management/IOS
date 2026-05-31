import SwiftUI

struct RecordNoticeView: View {
    @EnvironmentObject var coordinator: Coordinator
    @ObservedObject var settingVM: SettingView.ViewModel
    
    init(vm: SettingView.ViewModel) {
        self.settingVM = vm
    }
    
    var body: some View {
        VStack(spacing: 24) {
            SystemSettingAlert(isOn: $settingVM.systemIsOn)
            RecordListTile(title: "기록 전체 알림", isOn: $settingVM.totalRecordIsOn, systemIsOn: $settingVM.systemIsOn)
            Divider()
            RecordListTile(title: "하루 기록", subline: "메인 기록에 대한 미기록 알림", isOn: $settingVM.dailyIsOn, systemIsOn: $settingVM.systemIsOn)
            RecordListTile(title: "운동 기록", subline: "메인 기록에 대한 미기록 알림", isOn: $settingVM.exerciseIsOn, systemIsOn: $settingVM.systemIsOn)
            RecordListTile(title: "습관 기록", subline: "메인 기록에 대한 등록 시간 알림", isOn: $settingVM.habitIsOn, systemIsOn: $settingVM.systemIsOn)
            RecordListTile(title: "일정 기록", subline: "메인 기록에 대한 등록 시간 알림", isOn: $settingVM.scheduleIsOn, systemIsOn: $settingVM.systemIsOn)
            Spacer()
        }
        .padding()
        .seedsDayNavigationStyle(title: "") {
            coordinator.pop()
        }
        .task {
            settingVM.systemIsOn = await NotificationService.shared.requestNotificationPermission()
            
            if settingVM.systemIsOn { // 알림이 허용 되어 있다면 서버에 FCM Token 전송
                do {
                    let success = try await NotificationService.shared.fcmTokenReqeust()
                    debugPrint(success)
                } catch {
                    debugPrint("fcm 서버 전송 Error : \(error)")
                }
            }
        }
        .onChange(of: settingVM.systemIsOn) {
            if !settingVM.systemIsOn { // 시스템 알림 권한이 없는 경우
                settingVM.totalRecordIsOn = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                settingVM.systemIsOn = await NotificationService.shared.requestNotificationPermission()
            }
        }
    }
}
