import SwiftUI

struct ExerciseRecordCard: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var recordVM: RecordViewModel
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @State private var pressGesture: Bool = false
    @Binding var isDismiss: Bool
    let info: ExerciseResponse
    
    init(info: ExerciseResponse, isDismiss: Binding<Bool>) {
        self.info = info
        self._isDismiss = isDismiss
    }
    
    var body: some View {
        VStack(spacing: 16) {
            header
            Divider()
            detailRecords
            bottomNotes
            if !info.imageUrls.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(info.imageUrls, id: \.self) { url in
                            AsyncImage(url: URL(string: url)!, content: { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(.rect(cornerRadius: 8))
                            }, placeholder: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.Gray._400())
                                    .frame(width: 100, height: 100)
                            })
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.Gray._50())
        .clipShape(.rect(cornerRadius: 16))
        .onLongPressGesture {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        .contextMenu(menuItems: {
            Button(action: {
                coordinator.push(.exerciseRecordEdit(exerciseInfo: info))
            }, label: {
                Text("수정하기")
            })
            Button(action: {
                Task {
                    let success = await recordVM.deleteExercise(id: info.base.id)
                    sheetVM.visibleToast = success
                    sheetVM.toastMessage = RecordMethod.delete.getMessage()
                }
            }, label: {
                Text("삭제하기")
            })
        })
        .onTapGesture {
            coordinator.push(.exerciseRecordEdit(exerciseInfo: info))
        }
        .scaleEffect(pressGesture ? 0.95 : 1.0)
        
    }
    
    // TODO: Detail Header Content (운동 종류, 운동 이름, 소모 칼로리)
    private var header: some View {
        let exerciseObj: ExerciseObj = ExerciseObj.matchingExercise(info.exerciseType)
        
        return HStack {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 66, height: 66)
                Image(exerciseObj.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            
            Spacer()
            Text(exerciseObj.getName())
                .typography(.p18SemiBold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            Spacer()
            VStack(alignment: .trailing ,spacing: 2) {
                Text("소모 칼로리")
                    .typography(.p12Medium)
                Text("\(caloriesBurned) Kcal")
                    .typography(.p16SemiBold)
            }
        }
    }
    
    // TODO: Detail Records (몸무게, 운동 시간, 걸음 수)
    private var detailRecords: some View {
        VStack(alignment: .leading) {
            Text("세부 기록")
                .typography(.p14SemiBold)
            HStack {
                ForEach(Record.allCases, id: \.id) { record in
                    VStack(alignment: .leading, spacing: 10) {
                        Image(record.getImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            
                        VStack(alignment: .leading,spacing: 2) {
                            Text(record.getName())
                                .typography(.p12Medium)
                            Text(record.getValue(with: detailsValues[record.id]))
                                .typography(.p16SemiBold)
                        }
                    }
                    Spacer()
                    if Record.allCases.last?.id != record.id {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
            Divider()
        }
    }
    
    private var bottomNotes: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("운동 기록")
                .typography(.p14SemiBold)
                
            VStack(alignment: .leading, spacing: 6) {
                Text(info.dailyNote)
                    .typography(.p14Regular)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .multilineTextAlignment(.leading)
                
                Text(Date.dailyTimeRecordDateFormat(info.base.recordTime ?? []))
                    .typography(.p12Regular)
            }
        }
    }
}

// TODO: Int? 값 형변환
extension ExerciseRecordCard {
    var caloriesBurned: String {
        guard let kcal = info.caloriesBurned else { return "--" }
        return kcal == 0 ? "--" : String(kcal)
    }
    
    var exerciseTimeMinutes: String {
        guard let time = info.exerciseTimeMinutes else { return "--" }
        return time == 0 ? "--" : String(time)
    }
    
    var stepCount: String {
        guard let step = info.stepCount else { return "--" }
        return step == 0 ? "--" : String(step)
    }
    
    var weight: String {
        guard let weight = info.weight else { return "--" }
        return weight == 0 ? "--" : String(weight)
    }
}

extension ExerciseRecordCard {
    
    var detailsValues: [String] {
        [weight, exerciseTimeMinutes, stepCount]
    }
    
    enum Record: Int ,CaseIterable, Identifiable {
        case weight
        case timer
        case step
        
        
        var id: Int {
            self.rawValue
        }
        
        func getName() -> String {
            switch self {
                case .weight:
                    "몸무게"
                case .timer:
                    "운동 시간"
                case .step:
                    "걸음 수"
            }
        }
        
        func getImage() -> String {
            switch self {
                case .weight:
                    "DetailWeight"
                case .timer:
                    "DetailTimer"
                case .step:
                    "DetailStep"
            }
        }
        
        func getValue(with val: String) -> String {
            switch self {
                case .weight:
                    "\(val) Kg"
                case .timer:
                    "\(val) 분"
                case .step:
                    "\(val) 걸음"
            }
        }
    }
}

#Preview {
    ExerciseRecordCard(
        info: ExerciseResponse(
            base: RecordResponse(
                id: "testID",
                type: "EXERCISE",
                recordDate: [2025, 10, 5],
                recordTime: [14, 30],
                createdAt: [2025, 10, 5, 14, 0, 0],
                updatedAt: [2025, 10, 5, 14, 0, 0]
            ),
            exerciseType: "RUNNING",
            caloriesBurned: 300,
            exerciseTimeMinutes: 35,
            stepCount: 5000,
            weight: 70,
            dailyNote: "친구들이랑 농구했다 공을 통통 튕겨서 얍하고 넣엇다 무릎이 너무 아프고 힘들지만 재밋다",
            imageUrls: ["https://example.com/test.jpg"]
        ),
        isDismiss: .constant(false),
    )
}
