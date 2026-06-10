import SwiftUI
import AuthenticationServices

/// Apple 로그인의 프레젠테이션 및 델리게이트 처리를 격리하는 헬퍼 클래스입니다.
@MainActor
public final class AppleSignInHelper: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var loginContinuation: CheckedContinuation<AuthUserData?, Never>?
    private var windowAnchor: ASPresentationAnchor?
    
    /// Apple 로그인 요청을 수행하고 결과를 비동기적으로 반환합니다.
    ///
    /// - Returns: 인증 성공 시 사용자 데이터(`AuthUserData`), 실패 또는 취소 시 `nil`
    public func requestAppleSignIn() async -> AuthUserData? {
        self.windowAnchor = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first
            
        return await withCheckedContinuation { continuation in
            self.loginContinuation = continuation
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.email, .fullName]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let idToken = appleIDCredential.identityToken.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            let authUserData = AuthUserData(token: idToken, oAuthId: userIdentifier)
            loginContinuation?.resume(returning: authUserData)
            loginContinuation = nil
        default:
            loginContinuation?.resume(returning: nil)
            loginContinuation = nil
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loginContinuation?.resume(returning: nil)
        loginContinuation = nil
    }
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return windowAnchor ?? UIWindow()
    }
}
