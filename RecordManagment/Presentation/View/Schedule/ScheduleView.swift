import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var vm: ScheduleViewModel
    @FocusState var isFocused: Field?

    init(vm: ScheduleViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack {
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
                    MultiTextField(placeholder: "메모", text: memoBinding, isFocused: $isFocused)
                    Spacer().frame(height: 10)
                }
                .scrollIndicators(.hidden)
                RecordButton(method: .constant(.create), condition: .constant(false)) {}
                    .padding(.top, 10)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .navigationTitle("일정 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image("xmark")
                        .frame(maxWidth: 24, maxHeight: 24)
                        .higFullScreenBackSize()
                        .onTapGesture {
                            coordinator.dismissScreen()
                        }
                }
            }
            .sheet(isPresented: $vm.showNotificationSheet) {
                ScheduleNotificationSheet(
                    notification: notificationBinding
                )
            }
            .sheet(isPresented: $vm.showRepeatSheet) {
                ScheduleRepeatSheet(repeatData: repeatBinding)
            }
            .sheet(isPresented: $vm.showColorSheet) {
                ScheduleColorSheet(color: colorBinding)
            }
        }
    }
    
    @ViewBuilder
    private var scheduleNameField: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(colorBackground)
                .frame(width: 4, height: 52)
            TextField("일정 명", text: titleBinding)
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
        progress: Binding<PickerProgress>
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
                Text(notificationText(vm.notification))
                    .typography(.p16Regular)
                    .foregroundStyle(Color.Gray._600())
                Image(systemName: "chevron.right")
                    .scaledToFit()
                    .foregroundStyle(Color.Gray._900())
            }
            .onTapGesture {
                vm.showNotificationSheet.toggle()
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
                Text(repeatText)
                    .typography(.p16Regular)
                    .foregroundStyle(Color.Gray._600())
                Image(systemName: "chevron.right")
                    .scaledToFit()
                    .foregroundStyle(Color.Gray._900())
            }
            .onTapGesture {
                vm.showRepeatSheet.toggle()
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
                Circle().fill(colorBackground)
                Image(systemName: "chevron.right")
                    .scaledToFit()
                    .foregroundStyle(Color.Gray._900())
            }
            .onTapGesture {
                vm.showColorSheet.toggle()
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
    private var titleBinding: Binding<String> {
        Binding(
            get: { vm.title },
            set: { vm.setTitle($0) }
        )
    }
    
    private var memoBinding: Binding<String> {
        Binding(
            get: { vm.memo },
            set: { vm.setMemo($0) }
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
    
    private var dateProgressBinding: Binding<PickerProgress> {
        Binding(
            get: { vm.dateProgress },
            set: { vm.setDateProgress($0) }
        )
    }
    
    private var notificationBinding: Binding<ScheduleNotification> {
        Binding(
            get: { vm.notification },
            set: { vm.setNotification($0) }
        )
    }
    
    private var repeatBinding: Binding<ScheduleRepeat> {
        Binding(
            get: { vm.repeatData },
            set: {vm.setRepeatData($0)}
        )
    }
    
    private var colorBinding: Binding<ScheduleColor> {
        Binding(
            get: { vm.color },
            set: {vm.setColor($0)}
        )
    }
}

// MARK: - Helper

extension ScheduleView {
    private func datePickerFontColor(_ progress: PickerProgress) -> Color {
        switch vm.dateProgress {
        case .start, .end:
            return progress == vm.dateProgress ? Color.Gray._900() : Color.Gray._400()
        case .none:
            return Color.Gray._900()
        }
    }
    
    private func notificationText(_ notification: ScheduleNotification) -> String {
        switch notification.type {
        case .none:
            return "알림 없음"
        case .one_day_before:
            return "1일 전 (오전 9시)"
        case .two_day_before:
            return "2일 전 (오전 9시)"
        case .custom(_, _):
            return "시간 설정"
        }
    }
    
    private var repeatText: String {
        var str: String = ""
        switch vm.repeatData.type {
        case .none:
            return "반복 없음"
        case .day:
            str = "매일"
        case .week:
            str = "매주"
        case .month:
            str = "매월"
        case .year:
            str = "매년"
        }
        guard let repeatDate: Date = vm.repeatData.endsOn else { return str }
        return "\(str), \(Date.intergrationDateFormat(repeatDate, format: "yyyy년MM월dd일")) 종료"
    }
    
    private var colorBackground: Color {
        switch vm.color {
        case .Red:    return Color(hex: "#FF5B52")
        case .Orange: return Color.Primary.main()
        case .Yellow: return Color(hex: "#FFCC00")
        case .Green:  return Color(hex: "#34C759")
        case .Blue:   return Color(hex: "#007AFF")
        case .Navy:   return Color(hex: "#004080")
        case .Pink:   return Color(hex: "#FF2D55")
        case .Gray:   return Color.Gray._400()
        }
    }
}

#Preview {
    ScheduleView(vm: ScheduleViewModel())
}
