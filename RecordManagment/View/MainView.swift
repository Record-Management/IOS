//
//  MainView.swift
//  RecordManagment
//
//  Created by 김용해 on 9/4/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var rm: RouterView.ViewModel
    @EnvironmentObject var coordinator: Coordinator
    var loginManager: LoginNetworkManager = .init()
    var body: some View {
        VStack {
            Button("로그 아웃") {
                Task {
                    await loginManager.logout()
                    rm.currentState = .login
                    coordinator.popToRoot()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("회원 탈퇴") {
                Task {
                    await loginManager.WithdrawMembership()
                    rm.currentState = .login
                    coordinator.popToRoot()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationBarBackButtonHidden()
        .navigationTitle("메인 화면")
    }
}

#Preview {
    MainView()
}
