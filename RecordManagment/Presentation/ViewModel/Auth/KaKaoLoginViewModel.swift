import Foundation
import KakaoSDKUser


@MainActor
class KaKaoLoginViewModel: ObservableObject {
    @Published var token: String? = nil
    @Published var userState: UserState = .initialize
    let useCase: KaKaoLoginUseCase
    
    init(useCase: KaKaoLoginUseCase) {
        self.useCase = useCase
    }
    
    func login() async {
        self.userState = await useCase.login()
    }
    
    func logout() async {
        await useCase.logout()
    }
}
