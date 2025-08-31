//
//  SectionThreeView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/13/25.
//

import SwiftUI

struct SectionThreeView: View {
    @State private var selectedDate: Date = Date()
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
                DatePicker(
                    "", // 라벨 텍스트를 빈 문자열로
                    selection: $selectedDate,
                    displayedComponents: [.date] // 날짜만 선택
                )
                .datePickerStyle(.wheel)  // Wheel 스타일
                .labelsHidden()           // 라벨 숨김
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .scaleEffect(1.3)
                .clipped()
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
    SectionThreeView()
        .padding()
}
