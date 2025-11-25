import SwiftUI

struct AdministrationView: View {
    @AppStorage("SeeTheAdministrationPage") private var isPage: Bool = false
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("씨드데이 사용에 필요한\n접근 권한 허용 항목이에요.")
                .typography(.p22Bold)
            
            Spacer()
            
            BasicSeeDayButton(isOpen: .constant(true)) {
                isPage.toggle()
            }
        }
        .padding()
    }
}

#Preview {
    AdministrationView()
}
