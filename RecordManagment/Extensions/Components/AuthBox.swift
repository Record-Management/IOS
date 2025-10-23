//
//  AuthTestBox.swift
//  RecordManagment
//
//  Created by 김용해 on 10/8/25.
//

import SwiftUI

struct AuthBox: View {
    @EnvironmentObject var rm: RouterView.ViewModel
    @EnvironmentObject var coordinator: Coordinator
    let method: Escape
    let cancel: () -> Void
    
    init(method: Escape, cancel: @escaping() -> Void) {
        self.method = method
        self.cancel = cancel
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#222222").opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                Text(method == .logout ?  "로그아웃 하시겠습니까?" : "탈퇴를 진행 하시겠습니까?")
                    .typography(.p16SemiBold)
                    .padding(.bottom,8)
                Text(method == .logout ? "???" : "탈퇴 시 모든 정보가 삭제되며, 복구가 불가합니다.")
                    .typography(.p14Regular)
                    .foregroundStyle(Color.Gray._600())
                    .padding(.bottom, 16)
                HStack {
                    alertBox("닫기", bgColor: Color.Gray._100(), textColor: Color.Gray._400(), action: cancel)
                    
                    switch method {
                        case .logout:
                            alertBox("로그아웃", bgColor: Color.Primary.main(), textColor: .white) {
                                cancel()
                                Task {
                                    await rm.logout()
                                    coordinator.popToRoot()
                                }
                            }
                        case .withdraw:
                            alertBox("탈퇴하기", bgColor: Color.Error.main(), textColor: .white) {
                                cancel()
                                Task {
                                    await rm.withdraw()
                                    coordinator.popToRoot()
                                }
                            }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.horizontal, 32)
        }
    }
}

extension AuthBox {
    enum Escape {
        case logout     // 로그아웃
        case withdraw   // 회원 탈퇴
    }
    
    func alertBox(
        _ text: String,
        bgColor: Color,
        textColor: Color,
        action: @escaping() -> Void
    ) -> some View {
        Text(text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(bgColor)
            .foregroundStyle(textColor)
            .clipShape(.rect(cornerRadius: 8))
            .onTapGesture {
                action()
            }
    }
}

#Preview {
    AuthBox(method: .logout, cancel: {})
}
