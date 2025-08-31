//
//  SectionTwoView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//

import SwiftUI

struct SectionTwoView: View {
    @Binding var name: String
    var body: some View {
        VStack(alignment: .leading) {
            Image("Nickname")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 30, maxHeight: 30)
                .padding(.vertical, 10)
            Text("어떻게 불러드릴까요?\n기록 속 당신의 이름을 알려주세요.")
                .font(.system(size: 22, weight: .bold))
                .padding(.vertical, 10)
                .lineSpacing(11)
            Spacer()

            VStack(alignment: .leading) {
                TextField("닉네임 혹은 이름을 입력해 주세요.", text: $name)
                    .padding()
                    .background(Color(hex: "#F5F5F5"))
                    .clipShape(.rect(cornerRadius: 8))
                
                Spacer().frame(height: 6)
                
                Text("한글, 영문 최대 6글자 / 공백, 특수기호 입력 불가")
                    .font(.caption).foregroundStyle(Color(hex: "#9E9E9E"))
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.top, 58)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    SectionTwoView(name: .constant(""))
        .padding()
}
