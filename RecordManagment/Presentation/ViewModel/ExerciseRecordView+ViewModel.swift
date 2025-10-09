import SwiftUI
import PhotosUI

extension ExerciseRecordView {
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
        @Published var isAlert: Bool = false
        @Published var alertMessage: String = ""
        
        @Binding var selectedDate: Date?
        var serverImageUrls: [URL] = []
        let recordUseCase: RecordUseCase
        let imageUseCase: ImageUseCase
        let manager: ExerciseRecordManager = .init()
        var recordId: String = ""

        init(exercise: ExerciseObj, selectedDate: Binding<Date?> ,recordUseCase: RecordUseCase, imageUseCase: ImageUseCase) {
            self.exercise = exercise
            self._selectedDate = selectedDate
            self.recordUseCase = recordUseCase
            self.imageUseCase = imageUseCase
        }
        
        init(exerciseInfo: ExerciseResponse,selectedDate: Binding<Date?> = .constant(nil),recordUseCase: RecordUseCase, imageUseCase: ImageUseCase) {
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
        }
        
        // TODO: 기록 저장 / 수정 함수
        func submitExerciseRecord(isEditing: Binding<Bool>) async -> Bool {
            
            let result = await recordUseCase.exercisePerform(
                isEditing: isEditing.wrappedValue,
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
                case .success(_):
                    debugPrint("운동 기록 작성에 성공하였습니다")
                    return true
                case .failure(let err):
                    await MainActor.run {
                        switch err {
                            case .refreshTokenExpired:
                                isAlert = true
                                alertMessage = "로그인 후 이용해주세요"
                            case .invaildRequest:
                                isAlert = true
                                alertMessage = "잘못된 요청입니다."
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
                caloriesBurned: kcal == 0 ? nil : kcal,
                exerciseTimeMinutes: time == 0 ? nil : time,
                stepCount: step == 0 ? nil : step,
                weight: weight == 0 ? nil : weight,
                dailyNote: text,
                imageUrls: imageUrls,
                recordDate: Date.onBoardingFormet(selectedDate ?? .now),
                recordTime: Date.intergrationDateFormat(.now, format: "HH:mm")
            )
        }
    }
}
