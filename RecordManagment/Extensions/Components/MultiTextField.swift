//
//  MultiTextField.swift
//  RecordManagment
//
//  Created by 김용해 on 10/1/25.
//

import SwiftUI

struct MultiTextField: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: FocusState<Field?>.Binding
    
    init(placeholder: String = "나의 하루는 어땠나요?",text: Binding<String>, isFocused: FocusState<Field?>.Binding) {
        self.placeholder = placeholder
        self._text = text
        self.isFocused = isFocused
    }
    
    var body: some View {
        // TODO: 텍스트 필드 뷰
        VStack(alignment: .leading) {
            TextField(placeholder, text: $text, axis: .vertical)
                .font(.system(size: 16, weight: .regular))
                .focused(isFocused, equals: .content)
                .lineSpacing(8)
                .tracking(0)
                .padding([.top, .trailing, .leading], 14)
                .padding(.bottom, 10)
                .onChange(of: text) {
                    if text.count > 1000 {
                        text = String(text.prefix(1000))
                    }
                }
            
            Spacer()
            
            Text("\(text.count) / 1000")
                .typography(.p16Regular)
                .foregroundColor(isFocused.wrappedValue == .content ? Color.Gray._800() : Color.Gray._500())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
        }
        .frame(minHeight: 270, maxHeight: 270)
        .background(Color.Gray._100())
        .onTapGesture {
            isFocused.wrappedValue = .content
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

