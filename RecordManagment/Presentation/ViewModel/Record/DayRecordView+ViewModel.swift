import SwiftUI
import PhotosUI
import Combine

extension DayRecordView {
    final class ViewModel: ObservableObject {
        @Published var text: String = ""
        @Published var selectedItems: [PhotosPickerItem] = []
        @Published var selectedImages: [PhotoTransfer] = []
        @Published var isDismiss: Bool = false
        @Published var sheet: Bool = false
        @Published var emotion: EmotionObj
        @Published var error: RecordError? = nil
        @Published var method: RecordMethod
        @Published var isActive: Bool = false
        var dailySnapShot: DailySnapshot?
        
        var recordId: String = ""
        var date: Date = .now
        
        let recordUseCase: RecordUseCase
        let imageUseCase: ImageUseCase
        let repository: DefaultDailyRecordRepository = .init(manager: .shared)
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
            
            dailySnapShot = DailySnapshot(emotion: emotion, content: text, imageUrls: serverImageUrls.map { $0.absoluteString
            })
            
            Task {
                await receivedImages()
                await MainActor.run {
                    activeSubscriber()
                }
            }
        }
        
        // TODO: 기록 저장 / 수정 함수
        @MainActor
        func submitDailyRecord(method: Binding<RecordMethod>) async -> Bool {
            let result = await recordUseCase.dailyPerform(
                method: method.wrappedValue,
                selectedImages: selectedImages,
                makeForm: makeBody,
                create: { [weak self] form in
                    guard let self else { return .failure(.loginFailed) }
                    do {
                        let res = try await self.repository.create(form: form, type: "daily")
                        return .success(res)
                    } catch {
                        return .failure(.loginFailed)
                    }
                },
                update: { [weak self] form in
                    guard let self else { return .failure(.loginFailed) }
                    do {
                        let res = try await self.repository.update(recordId: self.recordId, form: form, type: "daily")
                        return .success(res)
                    } catch {
                        return .failure(.loginFailed)
                    }
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
            do {
                _ = try await repository.delete(recordId: recordId, type: "daily")
                return true
            } catch {
                debugPrint("하루 기록 삭제 실패 : \(error)")
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
                            var photo = PhotoTransfer(image: uiImage)
                            photo.serverUrl = url.absoluteString
                            selectedImages.append(photo)
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


// MARK: Edit Field Combine
extension DayRecordView.ViewModel {
    func activePublisher() -> AnyPublisher<Bool, Never> {
        guard let dailySnapShot else { return Just(false).eraseToAnyPublisher() }
        return Publishers.CombineLatest3($emotion, $text, $selectedImages)
            .map { emotion, text, images in
                emotion != dailySnapShot.emotion ||
                text != dailySnapShot.content ||
                self.imageCondition(images: images)
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func activeSubscriber() {
        activePublisher()
            .assign(to: &$isActive)
    }
    
    func imageCondition(images: [PhotoTransfer]) -> Bool {
        guard let dailySnapShot else { return false }
        let curremtImages = Set(images.compactMap { $0.serverUrl })
        
        return curremtImages != Set(dailySnapShot.imageUrls.map { $0 })
    }
}
