//
//  SocialView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//
import SwiftUI

struct SocialView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var rm: RouterView.ViewModel
    @StateObject var km: KaKaoLoginViewModel = .init()
    @StateObject var am: AppleLoginViewModel = .init()
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                VStack {
                    Text("씨앗에서 자라나는, 나의 하루")
                        .font(.custom("LaundryGothic",size: 16))
                        
                    Text("씨드데이")
                        .font(.custom("LaundryGothic", size: 60)).bold()
                        .foregroundStyle(Color.Primary.main())
                }
                .padding(.bottom, 30)
                
                Image("Splash")
                    .frame(maxWidth: .infinity)
                    .scaledToFit()
            }
            Spacer()
            Group {
                Button {
                    Task {
                        switch await km.login() {
                            case .register:
                                coordinator.push(.section)
                            case .main:
                                coordinator.push(.main)
                            default:
                                return
                        }
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
                        switch await am.login() {
                            case .register:
                                coordinator.push(.section)
                            case .main:
                                coordinator.push(.main)
                            default:
                                return
                        }
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
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
        .onDisappear {
            km.token = nil
        }
    }
}


#Preview {
    SocialView()
}
