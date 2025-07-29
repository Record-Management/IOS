//
//  RecordManagmentApp.swift
//  RecordManagment
//
//  Created by 김용해 on 7/22/25.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon

@main
struct RecordManagmentApp: App {
    
    init() {
        if let apiKey = Bundle.main.infoDictionary?["KAKAO_API_KEY"] as? String {
            KakaoSDK.initSDK(appKey: apiKey)
        }
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
