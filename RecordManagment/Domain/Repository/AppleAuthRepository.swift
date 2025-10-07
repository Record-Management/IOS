import Foundation

protocol AppleLoginRepository {
    // Login
    func login(authUserData: AuthUserData) async -> UserState
    // Logout
    func logout() async
}
