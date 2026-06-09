import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var coordinator: Coordinator
    var store: NotificationStore
    
    init(store: NotificationStore) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            if store.state.notices.isEmpty {
                NotificationEmptyView()
            } else {
                ScrollView {
                    NotificationList(
                        notifications: bindingNotice
                    ) { notification in
                        // 일단 시간으로 분류 - 오늘 Push인지 과거 Push인지
                        let noticeTime = notification.time
                        let calendar = Calendar.current
                        
                        if calendar.isDateInToday(noticeTime) {
                            notificationLogic(record: notification.record, toastMessage: "이미 기록을 작성했어요", isToday: true)
                        } else {
                            notificationLogic(record: notification.record, toastMessage: "지나간 기록은 기록할 수 없어요. 내일 또 만나요!", isToday: false)
                        }
                    }
                }
            }
        }
        .onAppear { store.send(.onAppear) }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .seedsDayNavigationStyle(title: "알림", action: {
            coordinator.pop()
        })
//        .noGoalPeriodView(
//            checkGoal: store.userStore.state.checkGoal
//        ) {
//            coordinator.push(.goalSelection)
//        }
    }
    
    // TODO: Notification 분기 처리 함수
    private func notificationLogic(record: NotificationFilter, toastMessage: String, isToday: Bool) {
        if store.recordStore.state.limit.canCreateRecord { // 미기록 사용자
            switch record {
            case .dailyReMinder:
                store.userStore.send(.setCurrentRecord(.daily))
                coordinator.present(.recordSelection)
            case .exerciseReMinder:
                store.userStore.send(.setCurrentRecord(.exercise))
                coordinator.present(.recordSelection)
            case .habitReMinder:
                store.userStore.send(.setCurrentRecord(.habit))
                coordinator.present(.recordSelection)
            case .scheduleReMinder:
                coordinator.pop()
            default:
                return
            }
            
//            if !isToday {
//                sheetVM.visibleToast = true
//                sheetVM.toastMessage = "지나간 기록은 기록할 수 없어요.\n오늘의 기록을 작성해 보는건 어떨까요?"
//            }
        } else { // 이미 기록한 사용자
            coordinator.pop()
//            sheetVM.visibleToast = true
//            sheetVM.toastMessage = toastMessage
        }
    }
    
    private var bindingNotice: Binding<[Notice]> {
        Binding(
            get: { store.state.notices },
            set: { store.send(.setNotices($0)) }
        )
    }
}

// MARK: Data Structure

extension NotificationView {
    var data: [Notice] {
        [
            Notice(
                record: .dailyReMinder,
                title: "하루 기록",
                time: Date().addingTimeInterval(-3600),
                text: "아직 '하루 기록'을 작성하지 않았어요. 하루의 작은 순간이 쌓이면 큰 변화가 돼요.",
                isRead: false
            ),
            Notice(
                record: .exerciseReMinder,
                title: "운동 기록",
                time: Date().addingTimeInterval(-36000),
                text: "아직 '운동 기록'을 작성하지 않았어요. 기록이 쌓일수록 습관이 되고, 어느새 운동이 자연스러워 질거에요.",
                isRead: true
            ),
            Notice(
                record: .habitReMinder,
                title: "습관 기록",
                time: Calendar.current.startOfDay(for: .now).addingTimeInterval(-500000),
                text: "아직 '습관 기록'을 작성하지 않았어요. 하루의 작은 순간이 쌓이면 큰 변화가 돼요.",
                isRead: true
            ),
        ]
    }
    
    var preview: some View {
        VStack(spacing: 0) {
            NotificationList(notifications: .constant([])) { _ in
                
            }
        }
    }
}
