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
                debugPrint("notifications : \(notifications)")
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
                let isRead = data.recentCheckedAt.map {
                    calcuratorNotificationIsRead(
                        Date.convertNotificationForIntArray($0),
                        Date.convertNotificationForIntArray(item.sentAt)
                    )
                } ?? false
                
                return Notice(
                    record: DropDownFilter.matchingType(type: item.mainRecordType),
                    time: Date.convertNotificationForIntArray(item.sentAt) ?? .now,
                    text: item.description,
                    isRead: isRead
                )
            }
        }
        
        func calcuratorNotificationIsRead(_ recentCheckedAt: Date?, _ sentAt: Date?) -> Bool {
            guard let recentCheckedAt, let sentAt else { return false }
            return sentAt <= recentCheckedAt
        }
    }
}


// MARK: Test Data Fetching
extension NotificationView.ViewModel {
    func getTest() async {
        let data: [NotificationItem] = [
            NotificationItem(mainRecordType: "EXERCISE", description: "운동 기록이 생성되었습니다.", sentAt: [2025, 10, 29, 12, 5, 30]),
            NotificationItem(mainRecordType: "HABIT", description: "습관 기록이 추가되었습니다.", sentAt: [2025, 10, 29, 12, 50, 30]),
            NotificationItem(mainRecordType: "DAILY", description: "하루 기록 저장되었습니다.", sentAt: [2025, 10, 29, 8, 5, 30]),
            NotificationItem(mainRecordType: "DAILY", description: "하루 기록 저장되었습니다.", sentAt: [2025, 10, 27, 7, 10, 55]),
            NotificationItem(mainRecordType: "EXERCISE", description: "운동 기록이 생성되었습니다", sentAt: [2025, 10, 28, 18, 20, 15])
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
