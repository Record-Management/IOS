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
        let imageService: FetchImageUseCases = .init()
        
        init(exercise: ExerciseObj) {
            self.exercise = exercise
        }
        
        // TODO: 기록 저장 함수
        func submitExerciseRecord(isEditing: Binding<Bool>) async -> Bool {
            var imageUrls: [String] = []
            let hasFile = !selectedImages.isEmpty
            
            if hasFile {
                let imageData: [Data?] = selectedImages.map{
                    $0.image.jpegData(compressionQuality: 0.8)
                }
                
                let result = await imageService.fileUpload(files: imageData)
                
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
            let form = makeBody(imageUrls: imageUrls)
            var data: Result<ExerciseDTO, LoginError>
            
            if isEditing.wrappedValue {
                data = .failure(.invaildRequest)
            } else {
                data = await manager.exerciseRecordCreate(form: form)
            }
            
            switch data {
                case .success(let res):
                    print("하루기록 성공 : \(res)")
                    return true
                case .failure(let failure):
                    
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
