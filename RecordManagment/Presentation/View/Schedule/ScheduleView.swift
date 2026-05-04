import SwiftUI

struct ScheduleView: View {
    @State private var text: String = ""
    @State private var multiText: String = ""
    @State private var location: String = ""
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
                MultiTextField(placeholder: "메모", text: $multiText, isFocused: $isFocused)
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
            TextField("일정 명", text: $text)
                .foregroundStyle(Color.Gray._400())
                .padding(14)
                .background(Color.Gray._100(), in: .rect(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 52)
    }
    
    @ViewBuilder
    private var dayPiclerLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
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
            Text("2026.12.12 (월)")
                .typography(.p16SemiBold)
                .foregroundStyle(Color.Gray._900())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.Gray._100())
                .clipShape(.rect(cornerRadius: 8))
                
            Image(systemName: "arrowshape.right.fill")
                .scaledToFit()
                .padding(.vertical, 8)
            Text("2026.12.13 (화)")
                .typography(.p16SemiBold)
                .foregroundStyle(Color.Gray._900())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.Gray._100())
                .clipShape(.rect(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
    }
    
    @ViewBuilder
    private var notificationLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "bell.badge.fill")
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
            Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
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
            Image(systemName: "location.circle")
                .scaledToFit()
            Text("위치")
                .foregroundStyle(Color.Gray._900())
                .typography(.p16SemiBold)
            Spacer().frame(width: 4)
            TextField("위치를 입력해주세요", text: $location)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Color.Gray._400())
        }
        .frame(maxWidth: .infinity, maxHeight: 52)
        .frame(minHeight: 52)
    }
    
    @ViewBuilder
    private var colorPicker: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
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
            Image(systemName: "calendar")
                .scaledToFit()
            Text("메모")
                .foregroundStyle(Color.Gray._900())
                .typography(.p16SemiBold)
        }
        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        ScheduleView()
    }
}
