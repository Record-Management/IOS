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
    
    func login() async {
        if (UserApi.isKakaoTalkLoginAvailable()) {
           await kakaoAppLaunchedLogin()
        } else {
            await kakaoWebViewLogin()
        }
        
        if let token = self.token {
            let result = try? await networkManager.login(socialType: .kakao, accessToken: token)
            
            switch result {
                case .success(let response):
                    switch response.statusCode {
                        case 200:
                            print("기존 사용자입니다")
                            self.userState = .main
                            if response.data.isNewUser {
                                print("기존 사용자인척 하는 신규 사용자입니다.")
                                self.userState = .register
                            }
                        case 201:
                            print("신규 사용자립니다")
                            self.userState = .register
                        default:
                            print("statusCode: \(response.statusCode)")
                            self.userState = .login
                    }
                    print("kakao login result : \(response)")
                case .failure(let err):
                    self.userState = .login
                    print("kakoLogin Error : \(err)")
                case .none:
                    return
            }
        }
    }
    
    func logout() async {
        await kakaoLogout()
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
    
    // TODO: 카카오 로그아웃
    func kakaoLogout() async {
        await withCheckedContinuation { continuation in
            UserApi.shared.logout {(error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("logout() success.")
                    self.token = nil
                }
                continuation.resume()
            }
        }
    }
}
