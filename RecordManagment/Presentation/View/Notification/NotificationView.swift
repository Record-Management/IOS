import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        ScrollView {
            preview
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
                time: Calendar.current.startOfDay(for: .now).addingTimeInterval(-3600),
                text: "아직 '하루 기록'을 작성하지 않았어요. 하루의 작은 순간이 쌓이면 큰 변화가 돼요.",
                isRead: false
            ),
            Notice(
                record: .exercise,
                time: Calendar.current.startOfDay(for: .now).addingTimeInterval(-7200),
                text: "아직 '운동 기록'을 작성하지 않았어요. 기록이 쌓일수록 습관이 되고, 어느새 운동이 자연스러워 질거에요.",
                isRead: true
            ),
            Notice(
                record: .habit,
                time: Calendar.current.startOfDay(for: .now).addingTimeInterval(-10800),
                text: "아직 '습관 기록'을 작성하지 않았어요. 하루의 작은 순간이 쌓이면 큰 변화가 돼요.",
                isRead: true
            ),
        ]
    }
    
    var preview: some View {
        VStack(spacing: 0) {
            ForEach(data, id: \.self) { notice in
                HStack(spacing: 10) {
                    VStack {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 0.72).foregroundStyle(Color.Gray._200())
                                .frame(maxWidth: 24, maxHeight: 24)
                            Image(notice.record.getImage())
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 16, maxHeight: 16)
                        }
                        Spacer()
                    }
                    VStack(alignment: .leading,spacing: 8) {
                        HStack {
                            Text(notice.record.getTitle())
                                .typography(.p14Medium)
                                .foregroundStyle(Color.Gray._500())
                            Spacer()
                            Text("2시간 전")
                                .typography(.p12Regular)
                                .foregroundStyle(Color.Gray._500())
                        }
                        Text(notice.text)
                            .typography(.p14Medium)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(notice.isRead ? .clear : Color(hex: "FFF5EC"))
            }
        }
    }
}


#Preview {
    NavigationStack {
        NotificationView()
    }
}

