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

class AppleLoginViewModel: NSObject ,ObservableObject {
    
    @Published var givenName: String = ""
    @Published var errorMessage: String = ""
    @Published var authUserData = AuthUserData()
    private var loginContinuation: CheckedContinuation<Bool, Never>?
    let useCase: AppleLoginUseCase
    
    init(useCase: AppleLoginUseCase) {
        self.useCase = useCase
    }
    
    func login() async -> UserState {
        await appleLogin()
        return await useCase.appleLogin(authUserData: authUserData)
    }
}

extension AppleLoginViewModel {
    // MARK: Apple Login Logic
    @MainActor @discardableResult
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

