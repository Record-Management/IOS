import SwiftUI

struct NotificationEmptyView: View {
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: size.height * 0.3)
                VStack(spacing: 10) {
                    Image("NullNotifications")
                    Text("새로운 알림이 없습니다.")
                        .typography(.p14Regular)
                        .foregroundStyle(Color.Gray._400())
                    Spacer()
                }
                .frame(height: size.height * 0.7)
            }
            .frame(width: size.width, height: size.height)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationEmptyView()
    }
}
