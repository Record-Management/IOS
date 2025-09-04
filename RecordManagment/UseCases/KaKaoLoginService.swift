//
//  KaKaoLoginService.swift
//  RecordManagment
//
//  Created by 김용해 on 9/4/25.
//

import SwiftUI
import KakaoSDKUser


class KaKaoLoginService {
    
    // TODO: 카카오 로그아웃
    @discardableResult
    func kakaoLogout() async -> Bool {
        await withCheckedContinuation { continuation in
            UserApi.shared.logout {(error) in
                if let error = error {
                    print(error)
                    continuation.resume(returning: false)
                }
                else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
}
