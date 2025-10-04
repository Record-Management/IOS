import SwiftUI
import PhotosUI

// ** Focued Field enum Value
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
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @StateObject var vm: ViewModel
    @FocusState var isFocused: Field?
    @State private var isEditing: Bool = false
    
    init(exercise: ExerciseObj) {
        _vm = StateObject(wrappedValue: ViewModel(exercise: exercise))
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
                    Image(vm.exercise.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100, maxHeight: 100)
                        .onTapGesture {
                            vm.sheet = true
                        }
                    Text(vm.exercise.getName())
                        .typography(.p16SemiBold)
                    inputGroup(title: "소모 칼로리", placeHolder: "0 kcal", number: $vm.kcal, focused: .kcal)
                    inputGroup(title: "운동 시간", placeHolder: "0 분", number: $vm.time, focused: .time)
                    inputGroup(title: "걸음 수", placeHolder: "0 걸음", number: $vm.step, focused: .step)
                    inputGroup(title: "몸무게", placeHolder: "0 Kg", number: $vm.weight, focused: .weight)
                    inputGroup(title: "나의 하루", placeHolder: "NAN", isMultiField: true)
                    ImagesHStack(selectedImages: $vm.selectedImages, selectedItems: $vm.selectedItems, isFocused: $isFocused)
                }
            }
            .scrollIndicators(.hidden)
            RecordButton(isEditing: .constant(false), text: $vm.text) {
                guard !vm.text.isEmpty else { return }
                
                let success = await vm.submitExerciseRecord(isEditing: $isEditing)
                if success {
                    coordinator.dismissScreen()
                }
                sheetVM.visibleToast = success
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationTitle("운동 기록")
        .sheet(isPresented: $vm.sheet) {
            exerciseReSelectionView
        }
        .alert("오류", isPresented: $vm.isAlert, actions: {
            Button("확인", role: .cancel) {
                if !isEditing {
                    coordinator.dismissScreen()
                }
            }
        }, message: {
            Text(vm.alertMessage)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image("xmark")
                    .frame(maxWidth: 24, maxHeight: 24)
                    .higFullScreenBackSize()
                    .onTapGesture {
                        withAnimation(.interactiveSpring) {
                            vm.isDismiss = true
                        }
                    }
            }
        }
        .overlay {
            if vm.isDismiss {
                DismissAlertView(isDismiss: $vm.isDismiss, isEditing: .constant(false))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = nil
        }
    }
    
    // TODO: TextLabel Group 뷰
    private func inputGroup(title: String, placeHolder: String, number: Binding<Int> = .constant(0), isMultiField: Bool = false, focused: Field? = nil) -> some View {
        
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
                MultiTextField(text: $vm.text, isFocused: $isFocused)
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
    
    // TODO: Exercise ReSelection View
    private var exerciseReSelectionView: some View {
        NavigationStack {
            VStack {
                ExerciseListView(title: "운동 재선택") { exercise in
                    vm.exercise = exercise
                    vm.sheet = false
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Image("xmark")
                            .frame(maxWidth: 24, maxHeight: 24)
                            .onTapGesture {
                                withAnimation(.interactiveSpring) {
                                    vm.sheet = false
                                }
                            }
                    }
                }
                Spacer()
            }
        }
        .presentationDetents([.height(UIScreen.main.bounds.height * 0.6)])
    }
}

#Preview {
    ExerciseRecordView(exercise: .baseball)
}
