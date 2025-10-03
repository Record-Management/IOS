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
        
        let recordService: RecordService = .shared
        let manager: ExerciseRecordManager = .init()
        
        init(exercise: ExerciseObj) {
            self.exercise = exercise
        }
        
        // TODO: 기록 저장 / 수정 함수
        func submitExerciseRecord(isEditing: Binding<Bool>) async -> Bool {
            
            let result = await recordService.submitRecord(
                isEditing: isEditing.wrappedValue,
                selectedImages: selectedImages,
                makeForm: makeBody,
                create: { form in
                    await manager.exerciseRecordCreate(form: form)
                },
                update: { form in
                    await manager.exerciseRecordCreate(form: form)
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
                            default:
                                isAlert = true
                                alertMessage = "서버에 문제가 있습니다."
                        }
                    }
                    return false
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
                recordDate: Date.onBoardingFormet(recordService.selectedDate ?? .now)
            )
        }
    }
}
