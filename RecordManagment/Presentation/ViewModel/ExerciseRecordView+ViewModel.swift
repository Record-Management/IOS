import SwiftUI
import PhotosUI
import Combine

extension ExerciseRecordView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var isDismiss: Bool = false
        @Published var kcal: Int = 0
        @Published var time: Int = 0
        @Published var step: Int = 0
        @Published var weight: Int = 0
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
        let recordUseCase: RecordUseCase
        let imageUseCase: ImageUseCase
        let manager: ExerciseRecordManager = .init()
        var recordId: String = ""

        init(exercise: ExerciseObj, selectedDate: Binding<Date?> ,recordUseCase: RecordUseCase, imageUseCase: ImageUseCase, method: RecordMethod) {
            self.exercise = exercise
            self._selectedDate = selectedDate
            self.recordUseCase = recordUseCase
            self.imageUseCase = imageUseCase
            self.method = method
            
            activeSubscriber()
        }
        
        init(exerciseInfo: ExerciseResponse,selectedDate: Binding<Date?> = .constant(nil),recordUseCase: RecordUseCase, imageUseCase: ImageUseCase, method: RecordMethod) {
            recordId = exerciseInfo.base.id
            self.exercise = ExerciseObj.matchingExercise(exerciseInfo.exerciseType)
            self.kcal = exerciseInfo.caloriesBurned ?? 0
            self.time = exerciseInfo.exerciseTimeMinutes ?? 0
            self.step = exerciseInfo.stepCount ?? 0
            self.weight = exerciseInfo.weight ?? 0
            self.text = exerciseInfo.dailyNote
            self.serverImageUrls = exerciseInfo.imageUrls.map { image in
                guard let url = URL(string: image) else { return URL.currentDirectory() }
                return url
            }
            self._selectedDate = selectedDate
            self.recordUseCase = recordUseCase
            self.imageUseCase = imageUseCase
            self.method = method
            
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
        
        // TODO: 기록 저장 / 수정 함수
        func submitExerciseRecord(method: Binding<RecordMethod>) async -> Bool {
            
            let result = await recordUseCase.exercisePerform(
                method: method.wrappedValue,
                selectedImages: selectedImages,
                makeForm: makeBody,
                create: { form in
                    await manager.exerciseRecordCreate(form: form)
                },
                update: { form in
                    await manager.exerciseRecordRead(form: form, recordId: recordId)
                }
            )
            
            switch result {
                case .success(let res):
                    if res.code == "E40408" {
                        error = .exerciseLimit
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
                recordDate: selectedDate != nil ? Date.onBoardingFormet(selectedDate ?? .now) : nil,
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
                active && !text.isEmpty
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
        
        return field.combineLatest($time,$exercise,$selectedImages)
            .map { active, time ,exercise ,image in
                (
                    active ||
                    time != snapShot.exerciseTimeMinutes ||
                    exercise.imageName != snapShot.exerciseType ||
                    image.count != snapShot.imageUrls.count
                )
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func editSwipeSubscriber() {
        editSwipePublisher()
            .assign(to: &$hasEditField)
    }
}

