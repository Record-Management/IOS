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
    
    func login() async {
        await withCheckedContinuation { continuation in
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.email, .fullName]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests() // 실행
            
            continuation.resume()
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
