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
    
    func login() async {
        if (UserApi.isKakaoTalkLoginAvailable()) {
           await kakaoAppLaunchedLogin()
        } else {
            await kakaoWebViewLogin()
        }
    }
    
    func logout() async {
        await kakaoLogout()
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
                    self.token = String(describing: oauthToken)
                }
            }
            continuation.resume()
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
                    self.token = String(describing: oauthToken)
                }
            }
            continuation.resume()
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
                }
            }
            continuation.resume()
        }
    }
}
