//
//  ContentView.swift
//  RecordManagment
//
//  Created by 김용해 on 7/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var coordinator = Coordinator()
    @StateObject var rm: RouterView.ViewModel = .init(
        useCase: RouterUseCase(
            repository: DefaultRouterRepository()
        )
    )
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .root) // default: Login
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    coordinator.build(sheet: sheet)
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
                    coordinator.build(fullScreenCover: cover)
                }
        }
        .environmentObject(coordinator)
        .environmentObject(rm)
        .alert(rm.alertMessage, isPresented: $rm.showAlert) {
            Button("확인", role: .cancel) { }
        }
    }
}

#Preview {
    ContentView()
}
