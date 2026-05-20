import SwiftUI

struct ScheduleNotificationSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var oldValue: ScheduleNotification = .default
    @State private var date: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }()
    @State private var showPicker: Bool = false
    @Binding var notification: ScheduleNotification
    @Binding var saveState: SaveState
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(ScheduleNotification.NotificationType.allCases) { type in
                        HStack {
                            Text(notificationText(type: type))
                                .typography(.p16Regular)
                                .foregroundStyle(Color.Gray._800())
                            Spacer()
                            if isSelected(type) {
                                Image("Check")
                                    .scaledToFit()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if case .custom = type {
                                let calendar = Calendar.current
                                let hour = calendar.component(.hour, from: date)
                                let minute = calendar.component(.minute, from: date)
                                notification.type = .custom(hour, minute)
                            } else {
                                notification.type = type
                            }
                        }
                    }
                }
                
                if isSelected(.custom(nil, nil)) {
                    Section {
                        timeSelect
                            .listRowInsets(EdgeInsets())
                    }
                }
            }
            .scheduleSheetStyle(
                title: "알림 설정",
                backAction: {
                    saveState = .exit(.notification(oldValue))
                    dismiss()
                },
                completeAction: {
                    dismiss()
                }
            )
            .onAppear {
                oldValue = notification
                saveState = .none
                if case .custom(let hour, let minute) = notification.type {
                    var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
                    components.hour = hour ?? 9
                    components.minute = minute ?? 0
                    date = Calendar.current.date(from: components) ?? .now
                }
            }
        }
    }
    
    @ViewBuilder
    private var timeSelect: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("시간 설정")
                .typography(.p16SemiBold)
                .foregroundStyle(Color.Gray._900())
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.clear)
                    .stroke(Color.Gray._100(), lineWidth: 1)
                Text(Date.dailyTimeRecordDateFormat(date))
                    .typography(.p16SemiBold)
                    .foregroundStyle(Color.Gray._900())
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 10)
            }
            .onTapGesture { showPicker.toggle() }
            
            if showPicker {
                VStack {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { date },
                            set: { newValue in
                                date = newValue
                                let calendar = Calendar.current
                                let hour = calendar.component(.hour, from: newValue)
                                let minute = calendar.component(.minute, from: newValue)
                                notification.type = .custom(hour, minute)
                            }
                        ),
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .font(.system(size: 28, weight: .bold))
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .contentShape(Rectangle())
                    completeButton
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var completeButton: some View {
        HStack {
            Spacer()
            Button {
                withAnimation(.interactiveSpring) {
                    showPicker.toggle()
                }
            } label: {
                Text("완료")
                    .typography(.p16SemiBold)
                    .foregroundStyle(Color.Gray._900())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
            }
        }
    }
}

// MARK: - Helper

extension ScheduleNotificationSheet {
    private func isSelected(_ type: ScheduleNotification.NotificationType) -> Bool {
        switch (notification.type, type) {
        case (.none, .none),
             (.one_day_before, .one_day_before),
             (.two_days_before, .two_days_before):
            return true
        case (.custom, .custom):
            return true
        default:
            return false
        }
    }

    private func notificationText(type: ScheduleNotification.NotificationType) -> String {
        switch type {
        case .none: return "알림 없음"
        case .one_day_before: return "1일 전 (오전 9:00)"
        case .two_days_before: return "2일 전 (오전 9:00)"
        case .custom(_, _): return "시간 설정"
        }
    }
}
