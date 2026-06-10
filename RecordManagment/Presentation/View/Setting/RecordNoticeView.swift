import SwiftUI

struct RecordNoticeView: View {
    @EnvironmentObject var coordinator: Coordinator
    let store: SettingStore
    
    init(store: SettingStore) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 24) {
            SystemSettingAlert(isOn: bindingSystemIsOn)
            RecordListTile(title: "기록 전체 알림", isOn: bindingTotalRecordIsOn, systemIsOn: bindingSystemIsOn)
            Divider()
            RecordListTile(title: "하루 기록", subline: "메인 기록에 대한 미기록 알림", isOn: bindingDailyIsOn, systemIsOn: bindingSystemIsOn)
            RecordListTile(title: "운동 기록", subline: "메인 기록에 대한 미기록 알림", isOn: bindingExerciseIsOn, systemIsOn: bindingSystemIsOn)
            RecordListTile(title: "습관 기록", subline: "메인 기록에 대한 등록 시간 알림", isOn: bindingHabitIsOn, systemIsOn: bindingSystemIsOn)
            RecordListTile(title: "일정 기록", subline: "메인 기록에 대한 등록 시간 알림", isOn: bindingScheduleIsOn, systemIsOn: bindingSystemIsOn)
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
                    let success = try await NotificationService.shared.fcmTokenReqeust()
                    debugPrint(success)
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
    
    private var bindingTotalRecordIsOn: Binding<Bool> {
        Binding(
            get: { store.state.totalRecordIsOn },
            set: { store.send(.toggleTotalRecord($0)) }
        )
    }
    
    private var bindingDailyIsOn: Binding<Bool> {
        Binding(
            get: { store.state.dailyIsOn },
            set: { store.send(.toggleDaily($0)) }
        )
    }
    
    private var bindingExerciseIsOn: Binding<Bool> {
        Binding(
            get: { store.state.exerciseIsOn },
            set: { store.send(.toggleExercise($0)) }
        )
    }
    
    private var bindingHabitIsOn: Binding<Bool> {
        Binding(
            get: { store.state.habitIsOn },
            set: { store.send(.toggleHabit($0)) }
        )
    }
    
    private var bindingScheduleIsOn: Binding<Bool> {
        Binding(
            get: { store.state.scheduleIsOn },
            set: { store.send(.toggleSchedule($0)) }
        )
    }
}
