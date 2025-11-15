//
//  SeeDayBottomCard.swift
//  RecordManagment
//
//  Created by 김용해 on 11/13/25.
//

import SwiftUI

struct SeeDayBottomCard: View {
    let title: String
    let cardTitle: String
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .typography(.p14Medium)
                .foregroundStyle(.white)
            Spacer()
            HStack(spacing: 4) {
                Text(cardTitle)
                    .typography(.p14SemiBold)
                    .padding(.leading, 16)
                Image(systemName: "chevron.forward")
                    .padding(.trailing, 10)
            }
            .padding(.vertical, 10)
            .foregroundStyle(Color.Primary.main())
            .background(.white)
            .clipShape(.rect(cornerRadius: 100))
            .onTapGesture {
                onTap()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.Primary.main())
        .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    SeeDayBottomCard(title: "새로운 목표를 세우고\n다른 하루를 시작해보세요", cardTitle: "새 목표 설정하기" ,onTap: {})
}
