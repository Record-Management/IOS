import SwiftUI

struct SettingView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @ObservedObject var resVM: RecordSelectionView.ViewModel // 내 정보 들어있는 vm
    @StateObject var vm: ViewModel
    
    init(resVM: RecordSelectionView.ViewModel) {
        self._vm = StateObject(wrappedValue: ViewModel(
            useCase: SettingUseCase(
                repository: DefaultSettingRepository()
            ),
            resVM: resVM
        ))
        self.resVM = resVM
    }

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
        ScrollView {
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
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    switch data.state {
                                        case .nick:
                                            coordinator.openSheet(.nickName(settingVM: vm))
                                        case .birth:
                                            vm.isShow.toggle()
                                        case .appNotice:
                                            coordinator.push(.appNotice(settingVM: vm))
                                        case .recordNotice:
                                            coordinator.push(.recordNotice(settingVM: vm))
                                        case .logout:
                                            vm.method = .logout
                                            vm.isAlert.toggle()
                                        case .withdraw:
                                            vm.method = .withdraw
                                            vm.isAlert.toggle()
                                        case .policies:
                                            UIApplication.shared.open(URL(string: policiesURL)!, options: [:], completionHandler: nil)
                                            return
                                        case .inQuiry:
                                            UIApplication.shared.open(URL(string: inQueryURL)!, options: [:], completionHandler: nil)
                                        case .test:
                                            Task {
                                                await vm.testGoalInit()
                                                coordinator.pop()
                                            }
                                        default:
                                            return
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
            .padding()
        }
        .overlay {
            ToastMessage(visibleToast: $sheetVM.visibleToast, toastMessage: sheetVM.toastMessage)
        }
        .showDatePickerModal(isShow: $vm.isShow ,selection: $vm.birth, title: "생일 설정", cancel: {
            vm.isShow.toggle()
        }, update: {
            Task {
                let success = await vm.updateBirth()
                vm.isShow.toggle()
                
                sheetVM.visibleToast = success
                sheetVM.toastMessage = "생일 정보가 수정되었습니다."
            }
        })
        .showAuthAlertView(isAlert: $vm.isAlert, method: vm.method) {
            vm.isAlert.toggle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .background(Color.Gray._100())
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
        let state: State
        
        init(title: String, value: String? = nil, socialType: SocialType? = nil, next: Bool, state: State) {
            self.title = title
            self.value = value
            self.socialType = socialType
            self.next = next
            self.state = state
        }
        
        enum State {
            case none           // 아무것도 없음
            case nick           // 닉네임
            case birth          // 생일
            case appNotice      // 앱 알림
            case recordNotice   // 기록별 알림
            case policies       // 약관 및 정책
            case inQuiry        // 문의 하기
            case logout         // 로그아웃
            case withdraw       // 탈퇴하기
            case test           // 목표 재설정 테스트
        }
    }
    
    func makeSettingDataSet(from data: User.UserData) -> [ListSet] {
        [
            ListSet(
                section: "내 정보",
                inner: [
                    InnerData(title: "닉네임", value: data.nickname, next: true, state: .nick),
                    InnerData(title: "생일", value: Date.settingBirthDate(data.birthDate), next: true, state: .birth),
                    InnerData(title: "소셜 계정", socialType: SocialType.matchingType(data.socialType), next: false, state: .none)
                ]
            ),
            ListSet(
                section: "알림 설정",
                inner: [
                    InnerData(title: "앱 알림", next: true, state: .appNotice),
                    InnerData(title: "기록별 알림", next: true, state: .recordNotice)
                ]
            ),
            ListSet(
                section: "기타",
                inner: [
                    InnerData(title: "약관 및 정책", next: true, state: .policies),
                    InnerData(title: "문의하기", next: true, state: .inQuiry),
                    InnerData(title: "로그아웃", next: false, state: .logout),
                    InnerData(title: "탈퇴하기", next: false, state: .withdraw),
                    InnerData(title: "목표 재설정 테스트", next: false, state: .test)
                ]
            )
        ]
    }
}

// MARK: Static Variables
extension SettingView {
    var policiesURL: String { "https://record-management.github.io/SeedDayTerms/" }
    var inQueryURL: String { "https://docs.google.com/forms/d/e/1FAIpQLSeJfrO0L_qm1SHhkYCTl-DmveZvr1MJQ2_Ec5j5oW_Ota_MfA/viewform?usp=publish-editor" }
}


// MARK: Preview Test data
extension SettingView {
    var dataSet: [ListSet] {
        [
            ListSet(
                section: "내 정보",
                inner: [
                    InnerData(title: "닉네임", value: "네즈코", next: true, state: .nick),
                    InnerData(title: "생일", value: "2000/10/19", next: true, state: .birth),
                    InnerData(title: "소셜 계정", socialType: .kakao, next: false, state: .none)
                ]
            ),
            ListSet(
                section: "알림 설정",
                inner: [
                    InnerData(title: "앱 알림", next: true, state: .appNotice),
                    InnerData(title: "기록별 알림", next: true, state: .recordNotice)
                ]
            ),
            ListSet(
                section: "기타",
                inner: [
                    InnerData(title: "약관 및 정책", next: true, state: .policies),
                    InnerData(title: "문의하기", next: true, state: .inQuiry),
                    InnerData(title: "로그아웃", next: false, state: .logout),
                    InnerData(title: "탈퇴하기", next: false, state: .withdraw)
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
        SettingView(resVM: .init(useCase: .init(repository: DefaultUserRepository())))
            .environmentObject(Coordinator())
    }
}

