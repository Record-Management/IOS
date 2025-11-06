import SwiftUI

struct NotificationEmptyView: View {
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: geo.size.height * 0.3)
                VStack(spacing: 10) {
                    Image("NullNotifications")
                    Text("새로운 알림이 없습니다.")
                        .typography(.p14Regular)
                        .foregroundStyle(Color.Gray._400())
                    Spacer()
                }
                .frame(height: geo.size.height * 0.7)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationEmptyView()
    }
}
