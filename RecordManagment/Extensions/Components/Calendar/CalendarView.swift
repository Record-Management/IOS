import SwiftUI


struct MiddleSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct CalendarView: View {
    @ObservedObject var vm: ViewModel // Calendar ViewModel
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @State private var datePickerSize: CGSize = .zero
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    var dragProgress: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 10)
                .zIndex(1)
            Group {
                if vm.dateMode {
                    DatePicker(
                        "", // 라벨 텍스트를 빈 문자열로
                        selection: $vm.selectedMonth,
                        displayedComponents: [.date] // 날짜만 선택
                    )
                    .datePickerStyle(.wheel)  // Wheel 스타일
                    .labelsHidden()           // 라벨 숨김
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: datePickerSize.height + Calendar.monthHeight)
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    .scaleEffect(1.3)
                    .clipped()
                    .onChange(of: vm.selectedMonth) {
                        vm.title = Calendar.monthAndYear(from: vm.selectedMonth)
                        vm.date = vm.selectedMonth
                    }
                } else {
                    middleDays
                        .onPreferenceChange(MiddleSizePreferenceKey.self) { newSize in
                            datePickerSize = newSize
                        }
                    
                    MonthCalendarView(
                        isDragging: false,
                        dragProgress: dragProgress,
                        title: $vm.title,
                        focused: $vm.focusedWeek,
                        selection: $vm.date,
                        currentRecord: $vm.currentRecord,
                        calendarRecord: $vm.calendarRecord,
                        selectedMonth: $vm.selectedMonth
                    )
                    .frame(maxHeight: Calendar.monthHeight)
                }
            }
            .onChange(of: sheetVM.visibleToast) {
                if sheetVM.visibleToast { // Toast가 활성화 되면 캘린더 업데이트
                    vm.currentRecord = vm.currentRecord
                }
            }
            .onChange(of: sheetVM.isCompleted) { _, newValue in
                vm.selectedMonth = .now
            }
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
    
    // TODO: 상단 현재 year, month 및 색상 뷰
    private var headerView: some View {
        HStack {
            HStack {
                Text(vm.title)
                    .typography(.p20Bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Image(systemName: "chevron.down")
            }
            .onTapGesture {
                withAnimation {
                    vm.dateMode.toggle() // active Date Mode
                }
            }
            Spacer()
            ZStack {
                Rectangle()
                    .fill(Color.Gray._100())
                    .frame(maxWidth: 64)
                    .clipShape(.rect(cornerRadius: 100))
                HStack(spacing: 2) {
                    Circle()
                        .fill(.white)
                        .frame(maxWidth: 30, maxHeight: 30)
                        .overlay {
                            Image(vm.currentRecord.getImage())
                                .resizable()
                                .scaledToFit()
                                .padding(3)
                        }
                    Image(systemName: "chevron.down")
                        .padding(.vertical, 5)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
            }
            .frame(maxHeight: 44)
            .onTapGesture {
                withAnimation(.interactiveSpring) {
                    vm.isFilterBox.toggle()
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            if vm.isFilterBox {
                FilterDropDownView(
                    currentRecord: $vm.currentRecord,
                    isFilterBox: $vm.isFilterBox,
                )
            }
        }
    }
    
    // TODO: 월 화 수 목 금 토 일
    private var middleDays: some View {
        LazyVGrid(columns: columns, spacing: 12.5) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .typography(.p14Medium)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity)
            }
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: MiddleSizePreferenceKey.self, value: geo.size)
                }
            )
        }
    }
}

extension CalendarView {
    var weekdays: [String] {
        ["일", "월", "화", "수", "목", "금", "토"]
    }
}

#Preview {
    CalendarView(vm: .init(
            useCase: CalendarUseCase(
                calendarRepository: DefaultCalendarRepository()
            ),
            recordVM: .init(
                useCase: RecordUseCase(
                    repository: DefaultRecordRepository()
                )
            )
        )
    )
    .environmentObject(MainSheetViewModel(
        useCase: MainSheetUseCase(
            repository: DefaultMainSheetRepository()
        )
    ))
}
