import SwiftUI

struct SectionTwoView: View {
    @Binding var name: String
    @Binding var currentProgress: SectionView.ProgressPage
    @Binding var isValidName: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("Nickname")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 30, maxHeight: 30)
                .padding(.vertical, 10)
            Text("어떻게 불러드릴까요?\n기록 속 당신의 이름을 알려주세요.")
                .typography(.p22Bold)
                
            Spacer()

            VStack(alignment: .leading) {
                TextField("닉네임 혹은 이름을 입력해 주세요.", text: $name)
                    .focused($isFocused)
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
                        if isFocused {
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
            .frame(maxHeight: .infinity)
            .padding(.top, 58)
            
            Spacer()
            Spacer()
        }
        .navigationBarBackButtonHidden(currentProgress == .name)
        .seeDayToolBar {
            withAnimation {
                currentProgress = .record
            }
        }
    }
}

#Preview {
    SectionTwoView(
        name: .constant(""), currentProgress: .constant(.name), isValidName: .constant(false))
        .padding()
}
