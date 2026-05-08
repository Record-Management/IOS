import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon

@main
struct RecordManagmentApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let appContainer: AppContainer
    @StateObject var coordinator: Coordinator
    
    init() {
        let container = AppContainer()
                
        self.appContainer = container
        self._coordinator = StateObject(wrappedValue: Coordinator(appContainer: container))
        
        if let apiKey = Bundle.main.infoDictionary?["KAKAO_API_KEY"] as? String {
            KakaoSDK.initSDK(appKey: apiKey)
        }
        AppReviewManager.shared.trackFirstLaunch()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
