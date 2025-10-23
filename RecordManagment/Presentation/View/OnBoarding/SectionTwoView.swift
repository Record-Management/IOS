import SwiftUI

struct SectionTwoView: View {
    @Binding var name: String
    @Binding var currentProgress: SectionView.ProgressPage
    @Binding var isValidName: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("Nickname")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 30, maxHeight: 30)
                .padding(.vertical, 10)
            Text("어떻게 불러드릴까요?\n기록 속 당신의 이름을 알려주세요.")
                .typography(.p22Bold)
                
            Spacer()

            NickNameField(name: $name, isFocused: $isFocused, isValidName: $isValidName)
            .frame(maxHeight: .infinity)
            .padding(.top, 58)
            
            Spacer()
            Spacer()
        }
        .navigationBarBackButtonHidden(currentProgress == .name)
        .seeDayToolBar {
            withAnimation {
                currentProgress = .record
            }
        }
    }
}

#Preview {
    SectionTwoView(
        name: .constant(""), currentProgress: .constant(.name), isValidName: .constant(false))
        .padding()
}
