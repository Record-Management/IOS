import SwiftUI
import PhotosUI
import Combine

extension DayRecordView {
    @MainActor
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
        
        private let imageUseCase: ImageUseCase
        private let repository: any RecordRepository<DailyFormat, DailyDTO>
        
        var serverImageUrls: [URL] = []
        
        init(
            emotion: EmotionObj,
            imageUseCase: ImageUseCase,
            method: RecordMethod,
            repository: any RecordRepository<DailyFormat, DailyDTO>
        ) {
            self.emotion = emotion
            self.imageUseCase = imageUseCase
            self.method = method
            self.repository = repository
        }
        
        // TODO: 기록 수정을 위한 생성자 날짜는 유지
        init(
            recordId: String,
            emotion: EmotionObj,
            text: String,
            serverImageUrls: [URL],
            date: Date,
            imageUseCase: ImageUseCase,
            method: RecordMethod,
            repository: any RecordRepository<DailyFormat, DailyDTO>
        ) {
            self.recordId = recordId
            self.emotion = emotion
            self.text = text
            self.serverImageUrls = serverImageUrls
            self.date = date
            self.imageUseCase = imageUseCase
            self.method = method
            self.repository = repository
            
            dailySnapShot = DailySnapshot(emotion: emotion, content: text, imageUrls: serverImageUrls.map { $0.absoluteString
            })
            
            Task {
                await receivedImages()
                await MainActor.run {
                    activeSubscriber()
                }
            }
        }
        
        // TODO: 기록 저장 / 수정 / 삭제 분기 함수
        func submitDailyRecord(method: Binding<RecordMethod>) async -> Bool {
            switch method.wrappedValue {
            case .create:
                return await createRecord()
            case .update:
                return await updateRecord()
            case .delete:
                return await removeRecord()
            }
        }
        
        // TODO: 하루 기록 생성
        private func createRecord() async -> Bool {
            do {
                // 1. 신규 이미지 업로드 및 URL 획득
                let imageUrls = try await imageUseCase.uploadAndMergeImages(selectedImages: selectedImages)
                
                // 2. 완성된 URL 목록으로 Body DTO 생성
                let form = makeBody(imageUrls: imageUrls)
                
                // 3. 리포지토리를 통해 서버에 생성 요청
                let res = try await repository.create(form: form)
                
                // 4. 에러 코드 예외 처리
                if res.code == "E40407" {
                    error = .dailyLimit
                    return false
                } else if res.code == "E40410" {
                    error = .totalLimit
                    return false
                }
                return true
            } catch {
                Log.error("하루 기록 생성 실패 : \(error)")
                return false
            }
        }
        
        // TODO: 하루 기록 수정
        private func updateRecord() async -> Bool {
            do {
                // 1. 신규 이미지 업로드 및 기존 URL 병합
                let imageUrls = try await imageUseCase.uploadAndMergeImages(selectedImages: selectedImages)
                
                // 2. 완성된 URL 목록으로 Body DTO 생성
                let form = makeBody(imageUrls: imageUrls)
                
                // 3. 리포지토리를 통해 서버에 수정 요청
                let result = try await repository.update(recordId: recordId, form: form)
                Log.info("수정 result : \(result)")
                return true
            } catch {
                Log.error("하루 기록 수정 실패 : \(error)")
                return false
            }
        }
        
        // TODO: 삭제 기능
        func removeRecord() async -> Bool {
            do {
                _ = try await repository.delete(recordId: recordId)
                return true
            } catch {
                Log.error("하루 기록 삭제 실패 : \(error)")
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

extension DayRecordView.ViewModel: Hashable, Equatable {
    nonisolated public static func == (lhs: DayRecordView.ViewModel, rhs: DayRecordView.ViewModel) -> Bool {
        lhs === rhs
    }
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
