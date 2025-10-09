protocol RouterRepository {
    func refreshLogin(completion: () -> Void) async -> UserState
    func logout() async
}
