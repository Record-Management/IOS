import SwiftUI

struct SectionFiveView: View {
    @Environment(OnBoardingStore.self) private var store
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("Bell")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 30, maxHeight: 30)
                .padding(.vertical, 10)
            Text("기록을 잊지 않게 알려드릴게요.\n알림을 설정 할까요?")
                .typography(.p22Bold)
                
            
            Spacer().frame(maxHeight: 50)
            
            Image("On_Borading")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, -16)
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .seeDayToolBar {
            // prev 상태로 이동
            withAnimation {
                store.send(.bindingCurrentProgress(.goal))
            }
        }
    }
}
