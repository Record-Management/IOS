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
        let manager: DailyRecordManager = .init()
        let imageService: FetchImageUseCases = .init()
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
        
        // TODO: 기록 저장 함수
        func submitDailyRecord(isEditing: Binding<Bool>) async -> Bool {
            var imageUrls: [String] = []
            let hasFile = !selectedImages.isEmpty
            
            if hasFile {
                let imageData: [Data?] = selectedImages.map{
                    $0.image.jpegData(compressionQuality: 0.8)
                }
                
                let result = await manager.fileUpload(files: imageData)
                
                switch result {
                case .success(let urls):
                    imageUrls = urls
                case .failure(let failure):
                    await MainActor.run {
                        self.getAlertMessage(err: failure)
                    }
                    return false
                }
            }
            
            let form = DailyFormat(
                emotion: emotion.id,
                content: text,
                imageUrls: imageUrls,
                recordDate: Date.intergrationDateFormat(date, format: "yyyy-MM-dd"),
                recordTime: Date.intergrationDateFormat(date, format: "HH:mm")
            )
            
            var data: Result<DailyDTO, LoginError>
            
            if isEditing.wrappedValue {
                data = await manager.dailyRecordRead(form: form, recordId: recordId)
            } else {
                data = await manager.dailyRecordCreate(form: form)
            }
            
            switch data {
                case .success(let res):
                    print("하루기록 성공 : \(res)")
                    return true
                case .failure(let failure):
                    print(failure)
                    await MainActor.run {
                        self.getAlertMessage(err: failure)
                    }
                    return false
            }
        }
        
        // TODO: 오류가 있음을 나타내는 Alert
        func getAlertMessage(err: LoginError) {
            switch err {
            case .refreshTokenExpired:
                isAlert = true
                alertMessage = "로그인 후 이용해주세요"
            default:
                isAlert = true
                alertMessage = "서버에 문제가 있습니다."
            }
        }
        
        // TODO: 생성자에서 받은 URL -> selectedImages전달
        func receivedImages() async {
            guard !serverImageUrls.isEmpty else { return }
            
            for url in serverImageUrls {
                Task {
                    let data = await imageService.fetchImage(url: url)
                    
                    await MainActor.run {
                        if let uiImage = UIImage(data: data) {
                            selectedImages.append(PhotoTransfer(image: uiImage))
                            
                        }
                    }
                }
            }
        }
    }
}
