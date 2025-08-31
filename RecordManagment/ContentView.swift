//
//  ContentView.swift
//  RecordManagment
//
//  Created by 김용해 on 7/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var coordinator = Coordinator()
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .login) // default: Login
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
    }
}

#Preview {
    ContentView()
}
