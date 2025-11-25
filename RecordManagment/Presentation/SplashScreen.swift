//
//  SplashScreen.swift
//  RecordManagment
//
//  Created by 김용해 on 11/25/25.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
        }
    }
}

#Preview {
    SplashScreen()
}
