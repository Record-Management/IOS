import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var vm: ViewModel = .init(
        useCase: NotificationUseCase(
            repository: DefaultNotificationRepository()
        )
    )
    
    var body: some View {
        ZStack {
            if vm.notices.isEmpty {
                ProgressView()
            } else {
                ScrollView {
                    NotificationList(notifications: $vm.notices)
                }
            }
        }
        .task {
//            await vm.getNotifications()
            await vm.getTest()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .seedsDayNavigationStyle(title: "알림", action: {
            coordinator.pop()
        })
    }
}


// MARK: Data Structure
extension NotificationView {
    struct Notice: Hashable {
        let record: DropDownFilter
        let time: Date
        let text: String
        let isRead: Bool
    }
}

extension NotificationView {
    var data: [Notice] {
        [
            Notice(
                record: .daily,
                time: Date().addingTimeInterval(-3600),
                text: "아직 '하루 기록'을 작성하지 않았어요. 하루의 작은 순간이 쌓이면 큰 변화가 돼요.",
                isRead: false
            ),
            Notice(
                record: .exercise,
                time: Date().addingTimeInterval(-36000),
                text: "아직 '운동 기록'을 작성하지 않았어요. 기록이 쌓일수록 습관이 되고, 어느새 운동이 자연스러워 질거에요.",
                isRead: true
            ),
            Notice(
                record: .habit,
                time: Calendar.current.startOfDay(for: .now).addingTimeInterval(-500000),
                text: "아직 '습관 기록'을 작성하지 않았어요. 하루의 작은 순간이 쌓이면 큰 변화가 돼요.",
                isRead: true
            ),
        ]
    }
    
    var preview: some View {
        VStack(spacing: 0) {
            NotificationList(notifications: .constant([]))
        }
    }
}


#Preview {
    NavigationStack {
        NotificationView()
    }
}

