//
//  AuthTestBox.swift
//  RecordManagment
//
//  Created by 김용해 on 10/8/25.
//

import SwiftUI

struct AuthTestBox: View {
    @EnvironmentObject var rm: RouterView.ViewModel
    let manager: LoginNetworkManager = .init()
    
    var body: some View {
        // TODO: 로그아웃, 회원탈퇴 Test Box
        Group {
            Button("logout") {
                Task {
                    await manager.logout()
                    await MainActor.run {
                        rm.currentState = .login
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            Button("회원 탈퇴") {
                Task {
                    await manager.WithdrawMembership()
                    await MainActor.run {
                        rm.currentState = .login
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    AuthTestBox()
}
