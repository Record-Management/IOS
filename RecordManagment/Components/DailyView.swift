//
//  DailyView.swift
//  RecordManagment
//
//  Created by 김용해 on 9/19/25.
//

import SwiftUI

struct DailyView: View {
    @EnvironmentObject var coordinator: Coordinator
    let dailyInfo: DailyResponse
    var imageData: Data?
    @State private var expanded: Bool = false
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                Image(dailyInfo.emotion)
                Spacer()
                Text(Date.dailyTimeRecordDateFormat(dailyInfo.recordTime))
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
        .onTapGesture {
            coordinator.present(.dailyRecordEdit(dailyInfo: dailyInfo))
        }
    }
}

#Preview {
    DailyView(dailyInfo: DailyResponse(id: "1", type: "Daily", emotion: "Happy", content: "두번째 하루기록을 적어내림으로서 이제 더이상 하루 기록을 작성할 수 없음 content영역이 3줄 이상 넘어가면 더보기 Text가 생기면서 …이 보이는걸 Test하고 더보기 눌렀을때 전체 Content영역이 보이는지 Test", imageUrls: ["https://seeday-images.s3.ap-northeast-2.amazonaws.com/records/images/8bf9bed9-88c3-4ee9-af3b-2290b8a8439c.jpeg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20250918T054112Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=AKIA3MO4YP6QXDFTWTOC%2F20250918%2Fap-northeast-2%2Fs3%2Faws4_request&X-Amz-Signature=8f8d5cab4e11b31047335e558bdfbe00196780514c7c7ed16bbdde7e90b775ad"], recordDate: [2025,9,18], recordTime: [9, 14], createdAt: [24], updatedAt: [23]))
        .padding()
}
