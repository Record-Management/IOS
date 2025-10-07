//
//  KaKaoLoginService.swift
//  RecordManagment
//
//  Created by 김용해 on 7/29/25.
//

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
        self.userState = await useCase.kakaoLogin()
    }
    
    func logout() async {
        await useCase.kakaoLogout()
    }
}
