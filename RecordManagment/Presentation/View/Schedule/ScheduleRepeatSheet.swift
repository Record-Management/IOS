import SwiftUI

struct ScheduleRepeatSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var repeatData: ScheduleRepeat
    @State private var showPicker: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(ScheduleRepeat.RepeatType.allCases, id: \.self) { type in
                        HStack {
                            Text(repeatText(type: type))
                                .typography(.p16Regular)
                                .foregroundStyle(Color.Gray._800())
                            Spacer()
                            if repeatData.type == type {
                                Image("Check")
                                    .scaledToFit()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            repeatData.type = type
                        }
                    }
                }
                
                Section {
                    toggleRepeatEndsOn
                        .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.insetGrouped)
            .scheduleSheetStyle(
                title: "반복 설정",
                backAction: { dismiss() },
                completeAction: { dismiss() }
            )
        }
    }
    
    @ViewBuilder
    private var toggleRepeatEndsOn: some View {
        Group {
            switch repeatData.type {
            case .none:
                EmptyView()
            default:
                VStack(spacing: 16) {
                    HStack(spacing: 0) {
                        Text("반복 종료일")
                            .typography(.p16SemiBold)
                            .foregroundStyle(Color.Gray._900())
                        Spacer()
                        Toggle(
                            "",
                            isOn: Binding(projectedValue: $repeatData.hasEndsOn)
                        )
                    }
                    if repeatData.hasEndsOn {
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.clear)
                                    .stroke(Color.Gray._100(), lineWidth: 1)
                                Text(Date.dailyRecordDateFormat(repeatData.endsOn ?? .now))
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
                                            get: { repeatData.endsOn ?? .now },
                                            set: { repeatData.endsOn = $0 }
                                        ),
                                        displayedComponents: [.date]
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
                    }
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

extension ScheduleRepeatSheet {
    private func repeatText(type: ScheduleRepeat.RepeatType) -> String {
        switch type {
        case .none:
            "반복 없음"
        case .day:
            "매일"
        case .week:
            "매주"
        case .month:
            "매월"
        case .year:
            "매년"
        }
    }
}
