//
//  RecordButton.swift
//  RecordManagment
//
//  Created by 김용해 on 10/1/25.
//

import SwiftUI

struct RecordButton: View {
    @Binding var method: RecordMethod
    @Binding var condition: Bool
    let task: () async -> Void
    
    var body: some View {
        VStack {
            Text(method == .update ? "수정하기" : "작성하기")
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(condition ? Color.Primary.main() : Color.Primary.lighter())
                .foregroundColor(condition ? .white : Color.Primary.light())
                .cornerRadius(8)
        }
        .onTapGesture {
            guard condition else { return }
            Task {
                await task()
            }
        }
        .padding(.bottom)
    }
}
