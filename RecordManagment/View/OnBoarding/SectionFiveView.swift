import SwiftUI

struct SectionFiveView: View {
    @Binding var currentProgress: SectionView.ProgressPage
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                  Button(action: {
                      // prev 상태로 이동
                      withAnimation {
                          currentProgress = .goal
                      }
                  }) {
                      Image(systemName: "chevron.left")
                          .higBackSize()
                          .foregroundStyle(Color.Gray._900())
                  }
            }
        }
    }
}


#Preview {
    NavigationStack {
        SectionFiveView(currentProgress: .constant(.notification))
            .padding()
    }
}
