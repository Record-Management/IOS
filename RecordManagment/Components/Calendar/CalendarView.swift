import SwiftUI

struct CalendarView: View {
    @StateObject private var vm: ViewModel = .init()
    @State private var focusedWeek: Week = .current
    @State private var title: String = Calendar.monthAndYear(from: .now)
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    var dragProgress: CGFloat = 1
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 10)
                .zIndex(1)
            middleDays
            
            MonthCalendarView(
                isDragging: false,
                dragProgress: dragProgress,
                title: $title,
                focused: $focusedWeek,
                selection: $vm.date,
                currentRecord: $vm.currentRecord,
                calendarRecord: $vm.calendarRecord,
                selectedMonth: $vm.selectedMonth
            )
            .frame(maxHeight: Calendar.monthHeight)
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
    
    // TODO: 상단 현재 year, month 및 색상 뷰
    private var headerView: some View {
        HStack {
            Text(title)
                .typography(.p20Bold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
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
        }
        .onTapGesture {
            withAnimation(.interactiveSpring) {
                vm.isFilterBox.toggle()
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
        }
    }
}

extension CalendarView {
    var weekdays: [String] {
        ["일", "월", "화", "수", "목", "금", "토"]
    }
}

#Preview {
    CalendarView()
}
