import SwiftUI

struct AppNoticeView: View {
    @EnvironmentObject var coordinator: Coordinator
    @ObservedObject var settingVM: SettingView.ViewModel
    
    init(vm: SettingView.ViewModel) {
        self.settingVM = vm
    }
    
    var body: some View {
        VStack(spacing: 24) {
            SystemSettingAlert(isOn: $settingVM.systemIsOn)
            RecordListTile(title: "목표 미설정 알림", subline: "목표 기록 미설정 시 알림", isOn: $settingVM.isOn, systemIsOn: $settingVM.systemIsOn)
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
                    let _ = try await NotificationService.shared.fcmTokenReqeust()
                } catch {
                    debugPrint("fcm 서버 전송 Error : \(error)")
                }
            }
        }
        .onChange(of: settingVM.systemIsOn) {
            if !settingVM.systemIsOn { // 시스템 알림 권한이 없는 경우
                settingVM.isOn = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                settingVM.systemIsOn = await NotificationService.shared.requestNotificationPermission()
            }
        }
    }
}
