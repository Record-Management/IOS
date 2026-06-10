import SwiftUI

struct SectionThreeView: View {
    @Environment(OnBoardingStore.self) private var store
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("Birth")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 30, maxHeight: 30)
                .padding(.vertical, 10)
            Text("당신의 특별한 날은 언제인가요?\n생년월일을 입력해주세요.")
                .typography(.p22Bold)
                
            Spacer()

            VStack(alignment: .leading) {
                DatePicker(
                    "", // 라벨 텍스트를 빈 문자열로
                    selection: bindingSelectedDate,
                    displayedComponents: [.date] // 날짜만 선택
                )
                .datePickerStyle(.wheel)  // Wheel 스타일
                .labelsHidden()           // 라벨 숨김
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .scaleEffect(1.3)
                .clipped()
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.top, 58)
            
            Spacer()
            Spacer()
        }
        .navigationBarBackButtonHidden(store.state.currentProgress == .birth)
        .seeDayToolBar {
            withAnimation {
                store.send(.bindingCurrentProgress(.name))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("건너뛰기")
                    .typography(.p16SemiBold)
                    .padding(.vertical)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            store.send(.bindingBirthPartSkip(true))
                            store.send(.bindingCurrentProgress(.goal))
                        }
                    }
            }
        }
    }
    
    private var bindingSelectedDate: Binding<Date> {
        Binding(
            get: { store.state.selectedDate },
            set: { store.send(.bindingSelectedDate($0)) }
        )
    }
}
