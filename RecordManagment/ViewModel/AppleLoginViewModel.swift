//
//  AppleLoginViewModel.swift
//  RecordManagment
//
//  Created by 김용해 on 7/29/25.
//

import SwiftUI
import AuthenticationServices

struct AuthUserData {
    var token: String = ""
    var oAuthId: String = ""
}

class AppleLoginViewModel: NSObject ,ObservableObject, AppleLoginInterface {
    
    
    @Published var givenName: String = ""
    @Published var errorMessage: String = ""
    @Published var authUserData = AuthUserData()
    private var loginContinuation: CheckedContinuation<Bool, Never>?
    
    let networkManager: LoginNetworkManager = .init()
    
    func login() async -> UserState {
        var result: Result<SocialLoginResponseDTO, LoginError>? = nil
        
        await appleLogin()
        if !authUserData.token.isEmpty {
            do {
                result = try await networkManager.login(socialType: .apple, accessToken: authUserData.token)
            } catch {
                print("err : \(error)")
            }
            
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
                    return .login
                }
            case .failure(let err):
                print("kakoLogin Error : \(err.localizedDescription)")
                return .login
            case .none:
                return .login
            }
        } else {
            return .login
        }
    }
    
    @discardableResult
    func appleLogin() async -> Bool {
        await withCheckedContinuation { continuation in
            loginContinuation = continuation
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.email, .fullName]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests() // 실행
        }
    }
    
    func logout() async {
        print("Log Out")
        print("현재 oAuthID : \(authUserData.oAuthId)")
        print("현재 Token : \(authUserData.token)")
        print("현재 이름 : \(givenName)")
    }
}

extension AppleLoginViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential: //Apple ID 자격 증명을 처리
                             
                let userIdentifier = appleIDCredential.user //사용자 식별자
                let fullName = appleIDCredential.fullName //전체 이름
                let idToken = appleIDCredential.identityToken! //idToken
                
                authUserData.oAuthId = userIdentifier
                authUserData.token = String(data: idToken, encoding: .utf8) ?? ""
                givenName = fullName?.givenName ?? ""
                
                loginContinuation?.resume(returning: true)
                loginContinuation = nil
            default:
                break
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No Found window")
        }
        return window
    }
}
