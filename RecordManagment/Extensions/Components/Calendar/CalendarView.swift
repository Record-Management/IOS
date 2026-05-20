import SwiftUI


struct MiddleSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct CalendarView: View {
    @ObservedObject var sheetVM: MainSheetViewModel
    @Binding var datePickerSize: CGSize
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    var dragProgress: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 10)
                .zIndex(1)
            Group {
                middleDays
                    .onPreferenceChange(MiddleSizePreferenceKey.self) { newSize in
                        datePickerSize = newSize
                    }
                
                MonthCalendarView(
                    isDragging: false,
                    dragProgress: dragProgress,
                    title: $sheetVM.title,
                    focused: $sheetVM.focusedWeek,
                    selection: $sheetVM.date,
                    currentRecord: $sheetVM.currentRecord,
                    calendarRecord: $sheetVM.calendarRecord,
                    selectedMonth: $sheetVM.selectedMonth,
                )
                .frame(maxHeight: Calendar.monthHeight)
            }
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
    
    // TODO: 상단 현재 year, month 및 색상 뷰
    private var headerView: some View {
        HStack {
            HStack {
                Text(sheetVM.title)
                    .typography(.p20Bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Image(systemName: "chevron.down")
            }
            .onTapGesture {
                withAnimation {
                    sheetVM.dateMode.toggle() // active Date Mode
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
                            Image(sheetVM.currentRecord.getImage())
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
                    sheetVM.isFilterBox.toggle()
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            if sheetVM.isFilterBox {
                FilterDropDownView(
                    currentRecord: $sheetVM.currentRecord,
                    isFilterBox: $sheetVM.isFilterBox,
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
