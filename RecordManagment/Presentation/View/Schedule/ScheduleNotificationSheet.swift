import SwiftUI

struct ScheduleNotificationSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var notification: ScheduleNotification
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ScheduleNotification.NotificationType.allCases, id: \.self) { type in
                    HStack {
                        Text(notificationText(type: type))
                            .typography(.p16Regular)
                            .foregroundStyle(Color.Gray._800())
                        Spacer()
                        if notification.type == type {
                            Image("Check")
                                .scaledToFit()
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        notification.type = type
                    }
                }
            }
            .scheduleSheetStyle(
                title: "알림 설정",
                backAction: { dismiss() },
                completeAction: { dismiss() }
            )
        }
    }
}

// MARK: - Helper

extension ScheduleNotificationSheet {
    private func notificationText(type: ScheduleNotification.NotificationType) -> String {
        switch type {
        case .none: return "알림 없음"
        case .one_day_before: return "1일 전 (오전 9시)"
        case .two_day_before: return "2일 전 (오전 9시)"
        case .custom: return "시간 설정"
        }
    }
}
