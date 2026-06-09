import SwiftUI

struct DailyRecordCard: View {
    @EnvironmentObject var coordinator: Coordinator
    @Bindable var store: MainStore
    
    let dailyInfo: DailyResponse
    @State private var expanded: Bool = false
    @Binding var isDismiss: Bool
    @State private var pressGesture: Bool = false
    
    init(
        dailyInfo: DailyResponse,
        isDismiss: Binding<Bool>,
        store: MainStore
    ) {
        self.dailyInfo = dailyInfo
        self._isDismiss = isDismiss
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                Image(dailyInfo.emotion)
                Spacer()
                Text(Date.dailyTimeRecordDateFormat(dailyInfo.base.recordTime ?? []))
                    .typography(.p12Regular)
                    .foregroundStyle(Color.Gray._700())
            }
            
            TruncatedContent(
                expanded: $expanded ,
                content: dailyInfo.content,
                lineLimit: 3
            )
            
            if !dailyInfo.imageUrls.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(dailyInfo.imageUrls, id: \.self) { url in
                            AsyncImage(url: URL(string: url)!, content: { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(.rect(cornerRadius: 8))
                            }, placeholder: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.Gray._400())
                                    .frame(width: 100, height: 100)
                            })
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.Gray._50())
        .clipShape(.rect(cornerRadius: 16))
        .scaleEffect(pressGesture ? 0.95 : 1.0)
        .onLongPressGesture {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        .contextMenu(menuItems: {
            Button(action: {
                coordinator.push(.dailyRecordEdit(dailyInfo: dailyInfo))
            }, label: {
                Text("수정하기")
            })
            Button(action: {
                store.recordStore.send(.deleteDaily(id: dailyInfo.base.id))
            }, label: {
                Text("삭제하기")
            })
        })
        .onTapGesture {
            coordinator.push(.dailyRecordEdit(dailyInfo: dailyInfo))
        }
    }
}
