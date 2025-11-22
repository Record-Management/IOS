import SwiftUI

struct NotificationList: View {
    @Binding var notifications: [NotificationView.Notice]
    let onTap: (NotificationView.Notice) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(notifications, id: \.self) { notification in
                HStack(spacing: 10) {
                    VStack {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 0.72).foregroundStyle(Color.Gray._200())
                                .frame(maxWidth: 24, maxHeight: 24)
                            Image(notification.record.getImage())
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 16, maxHeight: 16)
                        }
                        Spacer()
                    }
                    VStack(alignment: .leading,spacing: 8) {
                        HStack {
                            Text(notification.title)
                                .typography(.p14Medium)
                                .foregroundStyle(Color.Gray._500())
                            Spacer()
                            Text(Date.calcurateNotificationTime(notification.time))
                                .typography(.p12Regular)
                                .foregroundStyle(Color.Gray._500())
                        }
                        Text(notification.text)
                            .typography(.p14Medium)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(notification.isRead ? .clear : Color(hex: "FFF5EC"))
                .onTapGesture {
                    onTap(notification)
                }
            }
        }
    }
}
