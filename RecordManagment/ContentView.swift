//
//  ContentView.swift
//  RecordManagment
//
//  Created by 김용해 on 7/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var km: KaKaoLoginViewModel = .init()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("카카오톡 로그인") {
                Task {
                    await km.login()
                }
            }
            Button("로그 아웃") {
                Task {
                    await km.logout()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
