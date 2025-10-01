import SwiftUI

enum Field: Hashable {
    case kcal, time, step, weight, content
    
    func getName() -> String {
        switch self {
            case .kcal:
                "Kcal"
            case .time:
                "분"
            case .step:
                "걸음"
            case .weight:
                "Kg"
            case .content:
                ""
        }
    }
}

struct ExerciseRecordView: View {
    let exercise: ExerciseObj
    @State private var isDismiss: Bool = false
    @State private var kcal: Int = 0
    @State private var time: Int = 0
    @State private var step: Int = 0
    @State private var weight: Int = 0
    @State private var text: String = ""
    @FocusState var isFocused: Field?
    
    init(exercise: ExerciseObj) {
        self.exercise = exercise
        clearBackground()
    }
    
    var body: some View {
        NavigationStack {
            content
        }
    }
    
    private var content: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(exercise.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100, maxHeight: 100)
                    Text(exercise.getName())
                        .typography(.p16SemiBold)
                    inputGroup(title: "소모 칼로리", placeHolder: "0 kcal", number: $kcal, focused: .kcal)
                    inputGroup(title: "운동 시간", placeHolder: "0 분", number: $time, focused: .time)
                    inputGroup(title: "걸음 수", placeHolder: "0 걸음", number: $step, focused: .step)
                    inputGroup(title: "몸무게", placeHolder: "0 Kg", number: $weight, focused: .weight)
                    inputGroup(title: "나의 하루", placeHolder: "NAN", isMultiField: true)
                }
            }
            .scrollIndicators(.hidden)
            RecordButton(isEditing: .constant(false), text: $text) {
                
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationTitle("운동 기록")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image("xmark")
                    .frame(maxWidth: 24, maxHeight: 24)
                    .higFullScreenBackSize()
                    .onTapGesture {
                        withAnimation(.interactiveSpring) {
                            isDismiss = true
                        }
                    }
            }
        }
        .overlay {
            if isDismiss {
                DismissAlertView(isDismiss: $isDismiss, isEditing: .constant(false))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = nil
        }
    }
    
    // TODO: TextLabel Group 뷰
    func inputGroup(title: String, placeHolder: String, number: Binding<Int> = .constant(0), isMultiField: Bool = false, focused: Field? = nil) -> some View {
        
        var numberText: Binding<String> {
            Binding(
                get: {
                    if let focused = focused {
                        if isFocused == focused {
                            return number.wrappedValue == 0 ? "" : "\(number.wrappedValue)"
                        } else {
                            return number.wrappedValue == 0 ? "" : "\(number.wrappedValue) \(focused.getName())"
                        }
                    }
                    return ""
                },
                set: { newValue in
                    
                    let filtered = newValue
                        .replacingOccurrences(of: focused?.getName() ?? "", with: "")
                        .trimmingCharacters(in: .whitespaces)
                        .filter { $0.isNumber }
                    
                    if let value = Int(filtered) {
                        number.wrappedValue = value
                    } else {
                        if isFocused == focused {
                            number.wrappedValue = 0
                        }
                    }
                }
            )
        }
        
        return VStack(spacing: 10) {
            Text(title)
                .typography(.p14SemiBold)
                .frame(maxWidth: .infinity, alignment: .leading)
            if isMultiField {
                MultiTextField(text: $text, isFocused: $isFocused)
            } else {
                TextField(placeHolder, text: numberText)
                    .focused($isFocused, equals: focused)
                    .padding(14)
                    .background(Color.Gray._100())
                    .clipShape(.rect(cornerRadius: 8))
                    .keyboardType(.numberPad)
            }
        }
    }
}

#Preview {
    ExerciseRecordView(exercise: .baseball)
}
