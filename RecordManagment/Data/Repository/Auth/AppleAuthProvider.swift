import Foundation

@MainActor
struct AppleAuthProvider: SocialAuthProvider {
    let socialType: SocialType = .apple
    private let appleSignInHelper: AppleSignInHelper = .init()
    
    func login() async throws -> String {
        guard let state = await appleSignInHelper.requestAppleSignIn() else {
            Log.error("Failed to get Apple sign-in")
            throw LoginError.loginFailed
        }
        Log.info("Success to get Apple sign-in")
        return state.token
    }

    func logout() async -> Bool {
        return true
    }
}
