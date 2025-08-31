//
//  SocialView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//
import SwiftUI

struct SocialView: View {
    @StateObject var km: KaKaoLoginViewModel = .init()
    @StateObject var am: AppleLoginViewModel = .init()
    @EnvironmentObject var coordinator: Coordinator
    var body: some View {
        VStack {
            Rectangle()
                .frame(maxWidth: .infinity)
                .background(.gray)
            Spacer()
            Group {
                Button {
                    Task {
                        await km.login()
                    }
                } label: {
                    Label("카카오로 시작하기", image: "KaKao")
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#FEE500"))
                        .foregroundStyle(.black)
                }
                
                Button {
                    Task {
                        await am.login()
                    }
                } label: {
                    Label("Apple로 시작하기", image: "Apple")
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .foregroundStyle(.white)
                }
            }
            .font(.custom("Apple SD Gothic Neo", size: 15))
            .fontWeight(.semibold)
            .clipShape(.rect(cornerRadius: 6))
            .lineSpacing(7.5)
            .padding(.vertical, 9)
            
            Spacer()
        }
        .padding()
        .onChange(of: km.token) { token in
            if let _ = token {
                coordinator.push(.section)
            }
        }
    }
}


#Preview {
    SocialView()
}
