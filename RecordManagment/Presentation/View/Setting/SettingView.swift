import SwiftUI

struct SettingView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var resVM: RecordSelectionView.ViewModel // 내 정보 들어있는 vm
    @EnvironmentObject var sheetVM: MainSheetViewModel
    
    var body: some View {
        Group {
            if let data = resVM.user.data {
                let form = makeSettingDataSet(from: data)
                content(data: form)
            } else {
                ProgressView()
                    .onAppear {
                        coordinator.pop()
                    }
            }
        }
    }
    
    private func content(data : [ListSet]) -> some View {
        VStack(spacing: 24) {
            ForEach(data, id: \.self) { list in
                VStack(alignment: .leading, spacing: 10) {
                    Text(list.section)
                        .typography(.p16SemiBold)
                        .foregroundStyle(Color.Gray._900())
                    VStack(spacing: 16) {
                        ForEach(list.inner, id: \.self) { data in
                            HStack {
                                Text(data.title)
                                    .typography(.p14Medium)
                                    .foregroundStyle(Color.Gray._700())
                                Spacer()
                                if let value = data.value {
                                    Text(value)
                                        .typography(.p14Regular)
                                        .foregroundStyle(Color.Gray._400())
                                }
                                if let type = data.socialType { // icon
                                    Image(type.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                }
                                if data.next {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.Gray._400())
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 16))
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.Gray._100())
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .seedsDayNavigationStyle(title: "설정") {
            coordinator.pop()
        }
    }
}

extension SettingView {
    struct ListSet: Hashable {
        let section: String
        let inner: [InnerData]
    }

    struct InnerData: Hashable {
        let title: String
        let value: String?
        let socialType: SocialType?
        let next: Bool
        
        init(title: String, value: String? = nil, socialType: SocialType? = nil, next: Bool) {
            self.title = title
            self.value = value
            self.socialType = socialType
            self.next = next
        }
    }
    
    func makeSettingDataSet(from data: User.UserData) -> [ListSet] {
        [
            ListSet(
                section: "내 정보",
                inner: [
                    InnerData(title: "닉네임", value: data.nickname, next: true),
                    InnerData(title: "생일", value: Date.settingBirthDate(data.birthDate), next: true),
                    InnerData(title: "소셜 계정", socialType: SocialType.matchingType(data.socialType), next: false)
                ]
            ),
            ListSet(
                section: "알림 설정",
                inner: [
                    InnerData(title: "앱 알림", next: true),
                    InnerData(title: "기록별 알림", next: true)
                ]
            ),
            ListSet(
                section: "기타",
                inner: [
                    InnerData(title: "약관 및 정책", next: true),
                    InnerData(title: "문의하기", next: true),
                    InnerData(title: "로그아웃", next: false),
                    InnerData(title: "탈퇴하기", next: false)
                ]
            )
        ]
    }
}

// MARK: Preview Test data
extension SettingView {
    var dataSet: [ListSet] {
        [
            ListSet(
                section: "내 정보",
                inner: [
                    InnerData(title: "닉네임", value: "네즈코", next: true),
                    InnerData(title: "생일", value: "2000/10/19", next: true),
                    InnerData(title: "소셜 계정", socialType: .kakao, next: false)
                ]
            ),
            ListSet(
                section: "알림 설정",
                inner: [
                    InnerData(title: "앱 알림", next: true),
                    InnerData(title: "기록별 알림", next: true)
                ]
            ),
            ListSet(
                section: "기타",
                inner: [
                    InnerData(title: "약관 및 정책", next: true),
                    InnerData(title: "문의하기", next: true),
                    InnerData(title: "로그아웃", next: false),
                    InnerData(title: "탈퇴하기", next: false)
                ]
            )
        ]
    }
    
    // Preview
    var preview: some View {
        ForEach(dataSet, id: \.self) { list in
            VStack(alignment: .leading, spacing: 10) {
                Text(list.section)
                    .typography(.p16SemiBold)
                    .foregroundStyle(Color.Gray._900())
                VStack(spacing: 16) {
                    ForEach(list.inner, id: \.self) { data in
                        HStack {
                            Text(data.title)
                                .typography(.p14Medium)
                                .foregroundStyle(Color.Gray._700())
                            Spacer()
                            if let value = data.value {
                                Text(value)
                                    .typography(.p14Regular)
                                    .foregroundStyle(Color.Gray._400())
                            }
                            if let type = data.socialType { // social Type image
                                Image(type.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                            }
                            if data.next {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.Gray._400())
                            }
                        }
                    }
                }
                .padding()
                .background(.white)
                .clipShape(.rect(cornerRadius: 16))
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingView()
            .environmentObject(Coordinator())
    }
}
