import SwiftUI
import PhotosUI
import Combine

extension ExerciseRecordView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var isDismiss: Bool = false
        @Published var kcal: Int = 0
        @Published var time: Int = 0
        @Published var step: Int = 0
        @Published var weight: Double = 0
        @Published var text: String = ""
        @Published var selectedItems: [PhotosPickerItem] = []
        @Published var selectedImages: [PhotoTransfer] = []
        @Published var sheet: Bool = false
        @Published var exercise: ExerciseObj
        @Published var error: RecordError? = nil
        @Published var method: RecordMethod
        @Published var isActive: Bool = false
        @Published var hasEditField: Bool = false
        var exerciseSnapShot: ExerciseBody?
        
        @Binding var selectedDate: Date?
        var serverImageUrls: [URL] = []
        private let imageUseCase: ImageUseCase
        private let repository: any RecordRepository<ExerciseBody, ExerciseDTO>
        var recordId: String = ""

        init(
            exercise: ExerciseObj,
            imageUseCase: ImageUseCase,
            method: RecordMethod,
            repository: any RecordRepository<ExerciseBody, ExerciseDTO>
        ) {
            self.exercise = exercise
            self._selectedDate = .constant(.now)
            self.imageUseCase = imageUseCase
            self.method = method
            self.repository = repository
            
            activeSubscriber()
        }
        
        init(
            exerciseInfo: ExerciseResponse,
            selectedDate: Binding<Date?> = .constant(nil),
            imageUseCase: ImageUseCase,
            method: RecordMethod,
            repository: any RecordRepository<ExerciseBody, ExerciseDTO>
        ) {
            recordId = exerciseInfo.base.id
            self.exercise = ExerciseObj.matchingExercise(exerciseInfo.exerciseType)
            self.kcal = exerciseInfo.caloriesBurned ?? 0
            self.time = exerciseInfo.exerciseTimeMinutes ?? 0
            self.step = exerciseInfo.stepCount ?? 0
            self.weight = exerciseInfo.weight ?? 0.0
            self.text = exerciseInfo.dailyNote
            self.serverImageUrls = exerciseInfo.imageUrls.map { image in
                guard let url = URL(string: image) else { return URL.currentDirectory() }
                return url
            }
            self._selectedDate = selectedDate
            self.imageUseCase = imageUseCase
            self.method = method
            self.repository = repository
            
            // 수정 시 미리 값을 저장 (snapShot)
            exerciseSnapShot = ExerciseBody(
                exerciseType: exercise.imageName,
                caloriesBurned: kcal,
                exerciseTimeMinutes: time,
                stepCount: step,
                weight: weight,
                dailyNote: text,
                imageUrls: exerciseInfo.imageUrls,
                recordDate: nil,
                recordTime: Date.intergrationDateFormat(.now, format: "HH:mm")
            )
            
            activeSubscriber()
            editSwipeSubscriber()
        }
        
        // TODO: 기록 저장 / 수정 / 삭제 분기 함수
        func submitExerciseRecord(method: Binding<RecordMethod>) async -> Bool {
            switch method.wrappedValue {
            case .create:
                return await createRecord()
            case .update:
                return await updateRecord()
            case .delete:
                return await deleteExerciseRecord()
            }
        }
        
        // TODO: 운동 기록 생성
        private func createRecord() async -> Bool {
            do {
                // 1. 신규 이미지 업로드 및 URL 획득
                let imageUrls = try await imageUseCase.uploadAndMergeImages(selectedImages: selectedImages)
                
                // 2. 완성된 URL 목록으로 Body DTO 생성
                let form = makeBody(imageUrls: imageUrls)
                
                // 3. 리포지토리를 통해 서버에 생성 요청
                let res = try await repository.create(form: form)
                
                // 4. 에러 코드 예외 처리
                if res.code == "E40408" {
                    error = .exerciseLimit
                    return false
                } else if res.code == "E40410" {
                    error = .totalLimit
                    return false
                }
                return true
            } catch {
                debugPrint("운동 기록 생성 실패 : \(error)")
                return false
            }
        }
        
        // TODO: 운동 기록 수정
        private func updateRecord() async -> Bool {
            do {
                // 1. 신규 이미지 업로드 및 기존 URL 병합
                let imageUrls = try await imageUseCase.uploadAndMergeImages(selectedImages: selectedImages)
                
                // 2. 완성된 URL 목록으로 Body DTO 생성
                let form = makeBody(imageUrls: imageUrls)
                
                // 3. 리포지토리를 통해 서버에 수정 요청
                _ = try await repository.update(recordId: recordId, form: form)
                return true
            } catch {
                debugPrint("운동 기록 수정 실패 : \(error)")
                return false
            }
        }
        
        // TODO: 기록 삭제
        func deleteExerciseRecord() async -> Bool {
            do {
                _ = try await repository.delete(recordId: recordId)
                return true
            } catch {
                debugPrint("운동 기록 삭제 실패 : \(error)")
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
        func makeBody(imageUrls: [String] = []) -> ExerciseBody {
            ExerciseBody(
                exerciseType: exercise.imageName,
                caloriesBurned: kcal,
                exerciseTimeMinutes: time,
                stepCount: step,
                weight: weight,
                dailyNote: text,
                imageUrls: imageUrls,
                recordDate: selectedDate != nil ? Date.onBoardingFormet(.now) : nil,
                recordTime: Date.intergrationDateFormat(.now, format: "HH:mm")
            )
        }
    }
}


// MARK: View Combine for Field Active Button
extension ExerciseRecordView.ViewModel {
    func activePublisher() -> AnyPublisher<Bool, Never> {
        let exerciseActive = Publishers.CombineLatest4($kcal, $time ,$step, $weight)
            .map { kcal, time, step, weight in
                (kcal != 0 || time != 0 || step != 0 || weight != 0)
            }
            .eraseToAnyPublisher()
        
        return exerciseActive
            .combineLatest($text)
            .map { active, text in
                active && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            
    }
    
    func activeSubscriber() {
        activePublisher()
            .assign(to: &$isActive)
    }
}

// MARK: Edit Case Swipe Combine
extension ExerciseRecordView.ViewModel {
    func editSwipePublisher() -> AnyPublisher<Bool,Never> {
        guard let snapShot = self.exerciseSnapShot else {
            return Just(false).eraseToAnyPublisher()
        }
        
        let field = Publishers.CombineLatest4($kcal, $step, $weight, $text)
            .removeDuplicates(by: { prev, current in
                prev.0 == current.0 &&
                prev.1 == current.1 &&
                prev.2 == current.2 &&
                prev.3 == current.3
            })
            .map { kcal, step, weight, text in
                kcal != snapShot.caloriesBurned ||
                step != snapShot.stepCount ||
                weight != snapShot.weight ||
                text != snapShot.dailyNote
            }
        
        return field.combineLatest($time,$exercise, $selectedImages)
            .map { active, time ,exercise, images in
                (
                    active ||
                    time != snapShot.exerciseTimeMinutes ||
                    exercise.imageName != snapShot.exerciseType ||
                    self.imageCondition(images: images)
                )
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func editSwipeSubscriber() {
        editSwipePublisher()
            .assign(to: &$hasEditField)
    }
    
    func imageCondition(images: [PhotoTransfer]) -> Bool {
        guard let exerciseSnapShot else { return false }
        let curremtImages = Set(images.compactMap { $0.serverUrl })
        
        return curremtImages != Set(exerciseSnapShot.imageUrls.map { $0 })
    }
}

extension ExerciseRecordView.ViewModel: Hashable, Equatable {
    nonisolated public static func == (lhs: ExerciseRecordView.ViewModel, rhs: ExerciseRecordView.ViewModel) -> Bool {
        lhs === rhs
    }
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
