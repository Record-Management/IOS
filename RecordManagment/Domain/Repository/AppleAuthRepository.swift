import Foundation

protocol AppleLoginRepository {
    // Login
    func login(authUserData: AuthUserData) async -> UserState
}
