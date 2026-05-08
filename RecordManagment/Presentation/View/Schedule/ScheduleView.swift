import SwiftUI

struct ScheduleView: View {
    @StateObject private var vm: ScheduleViewModel = .init()
    @State private var method: RecordMethod = .create
    @FocusState var isFocused: Field?

    var body: some View {
        
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                scheduleNameField
                Spacer().frame(height: 24)
                dayPiclerLabel
                Spacer().frame(height: 16)
                datePicker
                Spacer().frame(height: 10)
                toggleWheelDatePicker(start: startDateBinding, end: endDateBinding, progress: dateProgressBinding)
                Spacer().frame(height: 16)
                notificationLabel
                Spacer().frame(height: 16)
                repeatLabel
                Spacer().frame(height: 24)
                Divider().background(Color.Gray._200())
                Spacer().frame(height: 10)
                locationField
                Spacer().frame(height: 10)
                Divider().background(Color.Gray._200())
                Spacer().frame(height: 24)
                colorPicker
                Spacer().frame(height: 16)
                memoLabel
                Spacer().frame(height: 10)
                MultiTextField(placeholder: "메모", text: multiTextBinding, isFocused: $isFocused)
                Spacer().frame(height: 10)
            }
            .scrollIndicators(.hidden)
            RecordButton(method: $method, condition: .constant(false)) {}
        }
        .seedsDayNavigationStyle(title: "일정 기록") {
            debugPrint("dismiss")
        }
        .padding()
    }
    
    @ViewBuilder
    private var scheduleNameField: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(Color.Primary.main())
                .frame(width: 4, height: 52)
            TextField("일정 명", text: textBinding)
                .foregroundStyle(Color.Gray._900())
                .padding(14)
                .background(Color.Gray._100(), in: .rect(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 52)
    }
    
    @ViewBuilder
    private var dayPiclerLabel: some View {
        HStack(spacing: 6) {
            Image("Calendar")
                .scaledToFit()
            Text("날짜")
                .foregroundStyle(Color.Gray._900())
                .typography(.p16SemiBold)
        }
        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
    }
    
    @ViewBuilder
    private var datePicker: some View {
        HStack(spacing: 12) {
            Text(Date.dailyRecordDateFormat(vm.startDate))
                .typography(.p16SemiBold)
                .foregroundStyle(datePickerFontColor(.start))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.Gray._100())
                .clipShape(.rect(cornerRadius: 8))
                .onTapGesture {
                    withAnimation(.interactiveSpring) {
                        vm.setDateProgress(.start)
                    }
                }
            Image(systemName: "chevron.right")
                .scaledToFit()
                .padding(.vertical, 8)
            Text(Date.dailyRecordDateFormat(vm.endDate))
                .typography(.p16SemiBold)
                .foregroundStyle(datePickerFontColor(.end))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.Gray._100())
                .clipShape(.rect(cornerRadius: 8))
                .onTapGesture {
                    withAnimation(.interactiveSpring) {
                        vm.setDateProgress(.end)
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
    }
    
    @ViewBuilder
    private func toggleWheelDatePicker(
        start: Binding<Date>,
        end: Binding<Date>,
        progress: Binding<ScheduleViewModel.PickerProgress>
    ) -> some View {
        VStack(spacing: 10) {
            Group {
                switch progress.wrappedValue {
                case .none:
                    EmptyView()
                case .start:
                    DatePicker(
                        "",
                        selection: start,
                        displayedComponents: [.date]
                    )
                case .end:
                    DatePicker(
                        "",
                        selection: end,
                        in: start.wrappedValue..., // 시작 날짜 이후로 제한
                        displayedComponents: [.date]
                    )
                }
            }
            .datePickerStyle(.wheel)
            .labelsHidden()
            .font(.system(size: 28, weight: .bold))
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .clipped()
            .contentShape(Rectangle())
            
            switch progress.wrappedValue {
            case .none:
                EmptyView()
            case .start, .end:
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.interactiveSpring) {
                            vm.datePickerCompleteButtonTapped()
                        }
                    } label: {
                        Text("완료")
                            .typography(.p16SemiBold)
                            .foregroundStyle(Color.Gray._900())
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle()) // 버튼 터치 영역 명시
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var notificationLabel: some View {
        HStack(spacing: 6) {
            Image("Notification")
                .scaledToFit()
            Text("알림")
                .foregroundStyle(Color.Gray._900())
                .typography(.p16SemiBold)
            Spacer()
            HStack(spacing: 6) {
                Text("알림 없음")
                    .typography(.p16Regular)
                    .foregroundStyle(Color.Gray._600())
                Image(systemName: "chevron.right")
                    .scaledToFit()
                    .foregroundStyle(Color.Gray._900())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
    }
    
    @ViewBuilder
    private var repeatLabel: some View {
        HStack(spacing: 6) {
            Image("Repeat")
                .scaledToFit()
            Text("반복")
                .foregroundStyle(Color.Gray._900())
                .typography(.p16SemiBold)
            Spacer()
            HStack(spacing: 6) {
                Text("반복 없음")
                    .typography(.p16Regular)
                    .foregroundStyle(Color.Gray._600())
                Image(systemName: "chevron.right")
                    .scaledToFit()
                    .foregroundStyle(Color.Gray._900())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
    }
    
    @ViewBuilder
    private var locationField: some View {
        HStack(spacing: 6) {
            Image("Compass")
                .scaledToFit()
            Text("위치")
                .foregroundStyle(Color.Gray._900())
                .typography(.p16SemiBold)
            Spacer().frame(width: 4)
            TextField("위치를 입력해주세요", text: locationBinding)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Color.Gray._900())
        }
        .frame(maxWidth: .infinity, maxHeight: 52)
        .frame(minHeight: 52)
    }
    
    @ViewBuilder
    private var colorPicker: some View {
        HStack(spacing: 6) {
            Image("Palette")
                .scaledToFit()
            Text("색상")
                .foregroundStyle(Color.Gray._900())
                .typography(.p16SemiBold)
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(Color.Primary.main())
                Image(systemName: "chevron.right")
                    .scaledToFit()
                    .foregroundStyle(Color.Gray._900())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
    }
    
    @ViewBuilder
    private var memoLabel: some View {
        HStack(spacing: 6) {
            Image("memo")
                .scaledToFit()
            Text("메모")
                .foregroundStyle(Color.Gray._900())
                .typography(.p16SemiBold)
        }
        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
    }
}

// MARK: - Binding

extension ScheduleView {
    private var textBinding: Binding<String> {
        Binding(
            get: { vm.text },
            set: { vm.setText($0) }
        )
    }
    
    private var multiTextBinding: Binding<String> {
        Binding(
            get: { vm.multiText },
            set: { vm.setMultiText($0) }
        )
    }
    
    private var locationBinding: Binding<String> {
        Binding(
            get: { vm.location },
            set: { vm.setLocation($0) }
        )
    }
    
    private var startDateBinding: Binding<Date> {
        Binding(
            get: { vm.startDate },
            set: { vm.setStartDate($0) }
        )
    }
    
    private var endDateBinding: Binding<Date> {
        Binding(
            get: { vm.endDate },
            set: { vm.setEndDate($0) }
        )
    }
    
    private var dateProgressBinding: Binding<ScheduleViewModel.PickerProgress> {
        Binding(
            get: { vm.dateProgress },
            set: { vm.setDateProgress($0) }
        )
    }
}

// MARK: - Helper

extension ScheduleView {
    private func datePickerFontColor(_ progress: ScheduleViewModel.PickerProgress) -> Color {
        switch vm.dateProgress {
        case .start, .end:
            return progress == vm.dateProgress ? Color.Gray._900() : Color.Gray._400()
        case .none:
            return Color.Gray._900()
        }
    }
}

#Preview {
    NavigationStack {
        ScheduleView()
    }
}
