import SwiftUI

struct SocialView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var rm: RouterView.ViewModel
    @StateObject var km: KaKaoLoginViewModel = .init(
        useCase: DefaultKaKaoLoginUseCase(
            repository: DefaultKaKaoRepository()
        )
    )
    @StateObject var am: AppleLoginViewModel = .init(
        useCase: DefaultAppleLoginUseCase(
            repository: DefaultAppleRepository()
        )
    )
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                VStack {
                    Text("씨앗에서 자라나는, 나의 하루")
                        .font(.custom("LaundryGothic",size: 16))
                        
                    Text("씨드데이")
                        .font(.custom("LaundryGothic", size: 60)).bold()
                        .foregroundStyle(Color.Primary.main())
                }
                .padding(.bottom, 30)
                
                Image("Splash")
                    .frame(maxWidth: .infinity)
                    .scaledToFit()
            }
            Spacer()
            Group {
                loginButton(
                    title: "카카오로 시작하기",
                    imageName: "KaKao",
                    backgroundColor: Color.Auth.kakao()
                ) {
                    await km.login()
                    switch km.userState {
                        case .register:
                            coordinator.push(.section)
                        case .main:
                            coordinator.push(.main)
                        default:
                            return
                    }
                }
                
                loginButton(
                    title: "Apple로 시작하기",
                    imageName: "Apple",
                    backgroundColor: Color.Auth.apple(),
                    foregroundColor: .white
                ) {
                    let state = await am.login()
                    switch state {
                        case .register:
                            coordinator.push(.section)
                        case .main:
                            coordinator.push(.main)
                        default:
                            return
                    }
                }
            }
            .font(.custom("Apple SD Gothic Neo", size: 15))
            .fontWeight(.semibold)
            .clipShape(.rect(cornerRadius: 6))
            .lineSpacing(7.5)
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
        .onDisappear {
            km.token = nil
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private func loginButton(
        title: String,
        imageName: String,
        backgroundColor: Color,
        foregroundColor: Color = .black,
        task: @escaping () async -> Void
    ) -> some View {
        Button {
            Task { await task() }
        } label: {
            Label(title, image: imageName)
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .foregroundStyle(foregroundColor)
        }
    }
}


#Preview {
    SocialView()
}
