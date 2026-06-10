import SwiftUI

struct AppNoticeView: View {
    @EnvironmentObject var coordinator: Coordinator
    let store: SettingStore
    
    init(store: SettingStore) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 24) {
            SystemSettingAlert(isOn: bindingSystemIsOn)
            RecordListTile(
                title: "목표 미설정 알림", 
                subline: "목표 기록 미설정 시 알림", 
                isOn: bindingIsOn, 
                systemIsOn: bindingSystemIsOn
            )
            Spacer()
        }
        .padding()
        .seedsDayNavigationStyle(title: "") {
            coordinator.pop()
        }
        .task {
            let systemIsOn = await NotificationService.shared.requestNotificationPermission()
            store.send(.updateSystemIsOn(systemIsOn))
            
            if systemIsOn { // 알림이 허용 되어 있다면 서버에 FCM Token 전송
                do {
                    let _ = try await NotificationService.shared.fcmTokenReqeust()
                } catch {
                    debugPrint("fcm 서버 전송 Error : \(error)")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                let systemIsOn = await NotificationService.shared.requestNotificationPermission()
                store.send(.updateSystemIsOn(systemIsOn))
            }
        }
    }
    
    // MARK: - Bindings
    
    private var bindingSystemIsOn: Binding<Bool> {
        Binding(
            get: { store.state.systemIsOn },
            set: { store.send(.updateSystemIsOn($0)) }
        )
    }
    
    private var bindingIsOn: Binding<Bool> {
        Binding(
            get: { store.state.isOn },
            set: { store.send(.toggleIsOn($0)) }
        )
    }
}
