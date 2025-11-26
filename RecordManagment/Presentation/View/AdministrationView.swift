import SwiftUI

struct AdministrationView: View {
    @AppStorage("SeeTheAdministrationPage") private var isPage: Bool = false
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("씨드데이 사용에 필요한\n접근 권한 허용 항목이에요.")
                .typography(.p22Bold)
            Spacer().frame(height: 60)
            VStack(alignment: .leading ,spacing: 40) {
                ForEach(data, id: \.self) { access in
                    accessRightListTile(access: access)
                }
            }
            
            Spacer()
            Spacer()
            
            BasicSeeDayButton(isOpen: .constant(true)) {
                isPage.toggle()
            }
        }
        .padding()
    }
}


// MARK: Data Structure
extension AdministrationView {
    struct AccessData: Hashable {
        let iconName: String
        let title: String
        let subtitle: String
    }
    
    var data: [AccessData] {
        [
            AccessData(iconName: "CameraIcon", title: "저장공간 (선택)", subtitle: "기록 작성 시 사진첩 접근에 사용"),
            AccessData(iconName: "MobileIcon", title: "사진 (선택)", subtitle: "기록 작성 시 사진 추가에 사용"),
            AccessData(iconName: "NotificationIcon", title: "알림 (선택)", subtitle: "서비스 이용의 푸시알림")
        ]
    }
}


// MARK: Method Utils
extension AdministrationView {
    @ViewBuilder
    private func accessRightListTile(access: AccessData) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.Gray._100())
                    .frame(width: 60, height: 60)
                Image(access.iconName)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(access.title)
                    .typography(.p16SemiBold)
                    .foregroundStyle(Color.Gray._900())
                Text(access.subtitle)
                    .typography(.p14Medium)
                    .foregroundStyle(Color.Gray._500())
            }
        }
    }
}

#Preview {
    AdministrationView()
}
