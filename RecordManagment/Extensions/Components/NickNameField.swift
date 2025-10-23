import SwiftUI

struct NickNameField: View {
    @Binding var name: String
    var isFocused: FocusState<Bool>.Binding
    @Binding var isValidName: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("닉네임 혹은 이름을 입력해 주세요.", text: $name)
                .focused(isFocused)
                .padding()
                .background(Color.Gray._100())
                .clipShape(.rect(cornerRadius: 8))
                .background {
                    if !name.isEmpty {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(isValidName ? .clear : Color.Error.main())
                    }
                }
                .overlay {
                    if isFocused.wrappedValue {
                        HStack {
                            Spacer()
                            Button {
                                name = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.Gray._400())
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 18)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            
            Spacer().frame(height: 6)
            
            Group {
                if name.isEmpty {
                    Text("한글, 영문 최대 6글자 / 공백, 특수기호 입력 불가")
                        .typography(.p12Regular)
                        .foregroundStyle(Color.Gray._500())
                }else {
                    Text("한글, 영문 최대 6글자 / 공백, 특수기호 입력 불가")
                        .typography(.p12Regular)
                        .foregroundStyle(isValidName ? Color.Gray._500() : Color.Error.main())
                }
            }
            Spacer()
        }
    }
}
