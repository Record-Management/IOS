//
//  RecordButton.swift
//  RecordManagment
//
//  Created by 김용해 on 10/1/25.
//

import SwiftUI

struct RecordButton: View {
    @Binding var isEditing: Bool
    @Binding var text: String
    let task: () async -> Void
    
    var body: some View {
        VStack {
            Text(isEditing ? "수정하기" : "작성하기")
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(text.isEmpty ? Color.Primary.lighter() : Color.Primary.main())
                .foregroundColor(text.isEmpty ? Color.Primary.light() : .white)
                .cornerRadius(8)
        }
        .onTapGesture {
            Task {
                await task()
            }
        }
    }
}
