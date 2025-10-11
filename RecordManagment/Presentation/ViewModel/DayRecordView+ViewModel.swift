import SwiftUI
import PhotosUI

extension DayRecordView {
    class ViewModel: ObservableObject {
        @Published var text: String = ""
        @Published var selectedItems: [PhotosPickerItem] = []
        @Published var selectedImages: [PhotoTransfer] = []
        @Published var isDismiss: Bool = false
        @Published var sheet: Bool = false
        @Published var emotion: EmotionObj
        @Published var error: RecordError? = nil
        @Published var method: RecordMethod
        
        var recordId: String = ""
        var date: Date = .now
        
        let recordUseCase: RecordUseCase
        let imageUseCase: ImageUseCase
        let manager: DailyRecordManager = .init()
        var serverImageUrls: [URL] = []
        
        init(emotion: EmotionObj, recordUseCase: RecordUseCase, imageUseCase: ImageUseCase, method: RecordMethod) {
            self.emotion = emotion
            self.recordUseCase = recordUseCase
            self.imageUseCase = imageUseCase
            self.method = method
        }
        
        // TODO: 기록 수정을 위한 생성자 날짜는 유지
        init(
            recordId: String,
            emotion: EmotionObj,
            text: String,
            serverImageUrls: [URL],
            date: Date,
            recordUseCase: RecordUseCase,
            imageUseCase: ImageUseCase,
            method: RecordMethod
        ) {
            self.recordId = recordId
            self.emotion = emotion
            self.text = text
            self.serverImageUrls = serverImageUrls
            self.date = date
            self.recordUseCase = recordUseCase
            self.imageUseCase = imageUseCase
            self.method = method
        }
        
        // TODO: 기록 저장 / 수정 함수
        @MainActor
        func submitDailyRecord(method: Binding<RecordMethod>) async -> Bool {
            let result = await recordUseCase.dailyPerform(
                method: method.wrappedValue,
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
                case .success(let res):
                    if res.code == "E40407" {
                        error = .dailyLimit
                        return false
                    } else if res.code == "E40410" {
                        error = .totalLimit
                        return false
                    }
                    
                    return true
                case .failure(let err):
                    debugPrint(err)
                    return false
            }
        }
        
        // TODO: 삭제 기능
        func removeRecord() async -> Bool {
            let result = await manager.dailyRecordRemove(recordId: recordId)
            
            switch result {
                case .success(let res):
                    return true
                case .failure(let err):
                    debugPrint("하루 기록 삭제 실패 : \(err)")
                    return false
            }
        }
        
        // TODO: 생성자에서 받은 URL -> selectedImages전달
        func receivedImages() async {
            guard !serverImageUrls.isEmpty else { return }
            
            for url in serverImageUrls {
                Task {
                    let data = await imageUseCase.getImage(url)
                    
                    await MainActor.run {
                        if let uiImage = UIImage(data: data) {
                            selectedImages.append(PhotoTransfer(image: uiImage))
                            
                        }
                    }
                }
            }
        }
        // TODO: DTO 객체 생성 함수
        @MainActor
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
