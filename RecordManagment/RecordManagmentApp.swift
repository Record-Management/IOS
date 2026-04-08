import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon

@main
struct RecordManagmentApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        if let apiKey = Bundle.main.infoDictionary?["KAKAO_API_KEY"] as? String {
            KakaoSDK.initSDK(appKey: apiKey)
        }
        AppReviewManager.shared.trackFirstLaunch()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL(perform: { url in
                if (AuthApi.isKakaoTalkLoginUrl(url)) {
                    _ = AuthController.handleOpenUrl(url: url)
                }
            })
        }
    }
}
