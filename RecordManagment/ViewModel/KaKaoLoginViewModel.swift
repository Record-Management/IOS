//
//  KaKaoLoginService.swift
//  RecordManagment
//
//  Created by 김용해 on 7/29/25.
//

import Foundation
import KakaoSDKUser


@MainActor
class KaKaoLoginViewModel: ObservableObject ,KaKaoLoginInterface {
    @Published var token: String? = nil
    @Published var userState: UserState = .initialize
    var networkManager: LoginNetworkManager = LoginNetworkManager()
    var kakaoService: KaKaoLoginService = .init()
    
    func login() async -> UserState {
        if (UserApi.isKakaoTalkLoginAvailable()) {
           await kakaoAppLaunchedLogin()
        } else {
            await kakaoWebViewLogin()
        }
        
        if let token = self.token {
            let result = try? await networkManager.login(socialType: .kakao, accessToken: token)
            
            switch result {
                case .success(let response):
                    print("kakao login result : \(response)")
                    switch response.statusCode {
                        case 200:
                            print("기존 사용자입니다")
                            if let data = response.data {
                                if let user = data.newUser,
                                   let completed = data.user?.onboardingCompleted,
                                   user || !completed {
                                    print("기존 사용자인척 하는 신규 사용자입니다.")
                                    return .register
                                }
                            }
                        return .main
                        case 201:
                            print("신규 사용자립니다")
                            return .register
                        default:
                            print("statusCode: \(response.statusCode)")
                            return .login
                    }
                case .failure(let err):
                    print("kakoLogin Error : \(err)")
                    return .login
                case .none:
                    return .login
            }
        } else {
            return .login
        }
    }
    
    func logout() async {
        await kakaoService.kakaoLogout()
        await networkManager.logout()
    }
    
    // TODO: 카카오톡이 설치된 경우 Login logic
    func kakaoAppLaunchedLogin() async {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    // 성공 시 동작 구현
                    self.token = oauthToken?.accessToken
                }
                continuation.resume()
            }
        }
    }
    
    // TODO: 카카오톡 설치 안된 경우 -> 웹뷰
    func kakaoWebViewLogin() async {
        await withCheckedContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")

                    // 성공 시 동작 구현
                    self.token = oauthToken?.accessToken
                }
                continuation.resume()
            }
        }
    }
}
