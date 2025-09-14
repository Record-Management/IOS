import SwiftUI


struct DayRecordView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var text: String = ""
    let emotion: EmotionObj
    let date: Date = .now
    
    var body: some View {
        NavigationStack {
            VStack {
                headerView(date)
                middleTextView()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .navigationBarBackButtonHidden()
            .navigationTitle("하루 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "xmark")
                        .onTapGesture {
                            coordinator.dismissScreen()
                        }
                }
            }
        }
        
    }
    
    // TODO: Header 뷰
    private func headerView(_ date: Date) -> some View {
        HStack(spacing: 0) {
            Image(emotion.id)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 80, maxHeight: 80)
                .padding(.trailing)
            VStack(alignment: .leading, spacing: 3) {
                Group {
                    Text("25.10.31 (화)")
                        .typography(.p16SemiBold)
                    Text("오전 02:32")
                        .typography(.p16Medium)
                }
                .foregroundStyle(Color.Gray._900())
            }
            
            Spacer()
        }
    }
    
    private func middleTextView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topLeading) {
                
                TextEditor(text: $text)
                    .font(.system(size: 16, weight: .regular))
                    .lineSpacing(8)
                    .tracking(0)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                
                // Placeholder
                if text.isEmpty {
                    Text("나의 하루는 어땠나요?")
                        .foregroundColor(.gray)
                        .padding(.top, 12)
                        .padding(.leading, 12)
                }

                // 우측 하단 글자 수
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(text.count)/1000")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(14)
                    }
                }
            }
            .frame(maxHeight: 250)
            .background(Color.Gray._100())
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    DayRecordView(emotion: .angry)
}
