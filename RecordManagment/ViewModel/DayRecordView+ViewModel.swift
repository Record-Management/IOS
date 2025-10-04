import SwiftUI
import PhotosUI

/// ** DailyRecord Form Data 형식
struct DailyFormat: Encodable {
    let emotion: String
    let content: String
    var imageUrls: [String]
    let recordDate: String
    let recordTime: String
}


extension DayRecordView {
    class ViewModel: ObservableObject {
        @Published var text: String = ""
        @Published var selectedItems: [PhotosPickerItem] = []
        @Published var selectedImages: [PhotoTransfer] = []
        @Published var isDismiss: Bool = false
        @Published var sheet: Bool = false
        @Published var emotion: EmotionObj
        @Published var isAlert: Bool = false
        @Published var alertMessage: String = ""
        var recordId: String = ""
        var date: Date = .now
        
        let recordService: RecordService = .shared
        let manager: DailyRecordManager = .init()
        var serverImageUrls: [URL] = []
        
        init(emotion: EmotionObj) {
            self.emotion = emotion
        }
        
        // TODO: 기록 수정을 위한 생성자 날짜는 유지
        init(
            recordId: String,
            emotion: EmotionObj,
            text: String,
            serverImageUrls: [URL],
            date: Date
        ) {
            self.recordId = recordId
            self.emotion = emotion
            self.text = text
            self.serverImageUrls = serverImageUrls
            self.date = date
        }
        
        // TODO: 기록 저장 / 수정 함수
        func submitDailyRecord(isEditing: Binding<Bool>) async -> Bool {
            let result = await recordService.submitRecord(
                isEditing: isEditing.wrappedValue,
                selectedImages: selectedImages,
                makeForm: makeBody,
                create: { form in
                    await manager.dailyRecordCreate(form: form)
                },
                update: { form in
                    await manager.dailyRecordRead(form: form, recordId: recordId)
                }
            )
            
            switch result {
                case .success(_):
                    debugPrint("기록 작성에 성공하였습니다")
                    return true
                case .failure(let err):
                    await MainActor.run {
                        switch err {
                            case .refreshTokenExpired:
                                isAlert = true
                                alertMessage = "로그인 후 이용해주세요"
                            case .invaildRequest:
                                isAlert = true
                                alertMessage = "하루 기록 제한을 초과했습니다.\n내일 시도해 주세요."
                            default:
                                isAlert = true
                                alertMessage = "서버에 문제가 있습니다."
                        }
                    }
                    return false
            }
        }
        
        // TODO: 생성자에서 받은 URL -> selectedImages전달
        func receivedImages() async {
            guard !serverImageUrls.isEmpty else { return }
            
            for url in serverImageUrls {
                Task {
                    let data = await recordService.imageService.fetchImage(url: url)
                    
                    await MainActor.run {
                        if let uiImage = UIImage(data: data) {
                            selectedImages.append(PhotoTransfer(image: uiImage))
                            
                        }
                    }
                }
            }
        }
        // TODO: DTO 객체 생성 함수
        func makeBody(imageUrls: [String] = []) -> DailyFormat {
            DailyFormat(
                emotion: emotion.id,
                content: text,
                imageUrls: imageUrls,
                recordDate: Date.intergrationDateFormat(date, format: "yyyy-MM-dd"),
                recordTime: Date.intergrationDateFormat(date, format: "HH:mm")
            )
        }
    }
}
