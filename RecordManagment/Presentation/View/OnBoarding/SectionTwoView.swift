import SwiftUI

struct SectionTwoView: View {
    @Environment(OnBoardingStore.self) private var store
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

            NickNameField(name: bindingName, isFocused: $isFocused, isValidName: bindingIsValidName)
            .frame(maxHeight: .infinity)
            .padding(.top, 58)
            
            Spacer()
            Spacer()
        }
        .navigationBarBackButtonHidden(store.state.currentProgress == .name)
        .seeDayToolBar {
            withAnimation {
                store.send(.bindingCurrentProgress(.record))
            }
        }
    }
    
    private var bindingName: Binding<String> {
        Binding(
            get: { store.state.name },
            set: { store.send(.bindingName($0)) }
        )
    }
    
    private var bindingIsValidName: Binding<Bool> {
        Binding(
            get: { store.state.isValidName },
            set: { _ in }
        )
    }
}
