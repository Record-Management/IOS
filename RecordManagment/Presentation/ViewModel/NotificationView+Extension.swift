import Foundation

extension NotificationView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var data: NotificationData? = nil
        @Published var notices: [Notice] = []
        
        let useCase: NotificationUseCase
        
        init(useCase: NotificationUseCase) {
            self.useCase = useCase
        }
        
        func getNotifications() async {
            do {
                let notifications = try await useCase.fetch()
                self.data = notifications
                self.notices = convertData(data) ?? []
            } catch {
                debugPrint("Notification Fetch Error : \(error)")
            }
        }
        
        // TODO: Convert NotificationItem -> Notice
        func convertData(_ data: NotificationData?) -> [Notice]? {
            guard let data = data else { return [] }
            
            return data.notifications.items.map { item in
                
                return Notice(
                    record: NotificationFilter.matchingNotificationFilterType(item.type),
                    title: item.title,
                    time: Date.convertNotificationForIntArray(item.sentAt) ?? .now,
                    text: item.message,
                    isRead: item.isRead ?? false
                )
            }
        }
    }
}


// MARK: Test Data Fetching
extension NotificationView.ViewModel {
    func getTest() async {
        let data: [NotificationItem] = [
            NotificationItem(id: "notification-123", type: "DAILY_RECORD_REMINDER", title: "하루 기록", message: "아직 '하루 기록'을 작성하지 않았어요. 하루의 작은 순간이 쌓이면 큰 변화가 돼요.", sentAt: [2025, 10, 29, 12, 50, 30], isRead: false),
            NotificationItem(id: "notification-123", type: "DAILY_RECORD_REMINDER", title: "하루 기록", message: "아직 '하루 기록'을 작성하지 않았어요. 하루의 작은 순간이 쌓이면 큰 변화가 돼요.", sentAt: [2025, 10, 29, 8, 5, 30], isRead: false),
            NotificationItem(id: "notification-123", type: "DAILY_RECORD_REMINDER", title: "하루 기록", message: "아직 '하루 기록'을 작성하지 않았어요. 하루의 작은 순간이 쌓이면 큰 변화가 돼요.", sentAt: [2025, 10, 29, 13, 50, 30], isRead: false),
            NotificationItem(id: "notification-123", type: "DAILY_RECORD_REMINDER", title: "하루 기록", message: "아직 '하루 기록'을 작성하지 않았어요. 하루의 작은 순간이 쌓이면 큰 변화가 돼요.", sentAt: [2025, 10, 29, 15, 50, 30], isRead: false),
        ]
        
        try? await Task.sleep(for: .seconds(1))
        
        let mockData = NotificationData(notifications: NotificationResponse(items: data, pageInfo: nil), recentCheckedAt: [2025, 10, 29, 12, 0, 0])
        self.notices = convertData(mockData) ?? []
    }
    
    func getEmptyViewTest() async {
        try? await Task.sleep(for: .seconds(1))
        
        self.notices = []
    }
}
