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
    
    init(exercise: ExerciseObj, selectedDate: Binding<Date?>) {
        _vm = StateObject(wrappedValue: ViewModel(
            exercise: exercise,
            selectedDate: selectedDate,
            recordUseCase: RecordUseCase(
                repository: DefaultRecordRepository()
            ),
            imageUseCase: ImageUseCase(
                repository: DefaultImageRepository()
            ),
            method: .create
        ))
    }
    
    init(exerciseInfo: ExerciseResponse, selectedDate: Binding<Date?> = .constant(nil)) {
        _vm = StateObject(wrappedValue: .init(
            exerciseInfo: exerciseInfo,
            selectedDate: selectedDate,
            recordUseCase: RecordUseCase(
                repository: DefaultRecordRepository()
            ),
            imageUseCase: ImageUseCase(
                repository: DefaultImageRepository()
            ),
            method: .update
        ))
    }
    
    var body: some View {
        switch vm.method {
            case .update, .delete:
                content
                    .task {
                        await vm.receivedImages()
                    }
            case .create:
                NavigationStack {
                    content
                }
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
                    HStack(spacing: 6) {
                        Text("운동 기록")
                            .typography(.p16SemiBold)
                        Text("1개 이상 필수 입력")
                            .typography(.p14Regular)
                            .foregroundStyle(Color.Gray._400())
                        Spacer()
                    }
                    .padding(.bottom, -8)
                    inputGroup(title: "소모 칼로리", placeHolder: "0 kcal", number: $vm.kcal, focused: .kcal)
                    inputGroup(title: "운동 시간", placeHolder: "0 분", number: $vm.time, focused: .time)
                    inputGroup(title: "걸음 수", placeHolder: "0 걸음", number: $vm.step, focused: .step)
                    inputGroup(title: "몸무게", placeHolder: "0 Kg", number: $vm.weight, focused: .weight)
                    Divider().foregroundStyle(Color.Gray._200())
                    inputGroup(title: "나의 하루", placeHolder: "NAN", isMultiField: true)
                    ImagesHStack(selectedImages: $vm.selectedImages, selectedItems: $vm.selectedItems, isFocused: $isFocused)
                }
            }
            .scrollIndicators(.hidden)
            RecordButton(
                method: $vm.method,
                condition: vm.method == .update ? .constant(vm.isActive && vm.hasEditField) : .constant(vm.isActive)
            ) {
                guard !vm.text.isEmpty else { return }
                
                let success = await vm.submitExerciseRecord(method: $vm.method)
                
                switch vm.method {
                    case .create:
                        coordinator.dismissScreen()
                    case .update:
                        coordinator.pop()
                    case .delete:
                        return
                }
                
                sheetVM.toastMessage = vm.method.getMessage()
                sheetVM.visibleToast = success
                sheetVM.error = vm.error
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationTitle("운동 기록")
        .sheet(isPresented: $vm.sheet) {
            exerciseReSelectionView
        }
        .onChange(of: vm.isActive && vm.hasEditField, initial: true) {
            if vm.isActive && vm.hasEditField {
                BackSwipeManager.shared.updatePopGesture(false)
            } else {
                BackSwipeManager.shared.updatePopGesture(true)
            }
        }
        .toolbar {
            if vm.method == .update || vm.method == .delete {
                ToolbarItem(placement: .topBarLeading) {
                      Button(action: {
                          if vm.isActive && vm.hasEditField {
                              vm.isDismiss = true
                          } else {
                              coordinator.pop()
                          }
                      }) {
                          Image(systemName: "chevron.left")
                              .higBackSize()
                              .foregroundStyle(Color.Gray._900())
                      }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(vm.method == .update ? "trash" : "xmark")
                    .frame(maxWidth: 24, maxHeight: 24)
                    .higFullScreenBackSize()
                    .onTapGesture {
                        withAnimation(.interactiveSpring) {
                            vm.isDismiss = true
                            if vm.method == .update {
                                vm.method = .delete
                            }
                        }
                    }
            }
        }
        .overlay {
            if vm.isDismiss {
                DismissAlertView(
                    isDismiss: $vm.isDismiss,
                    method: $vm.method
                ) {
                    // 삭제
                    Task {
                        let success = await vm.deleteExerciseRecord()
                        if success {
                            if vm.method == .delete {
                                coordinator.pop()
                            } else {
                                vm.isDismiss = false
                            }
                            sheetVM.visibleToast = success
                            sheetVM.toastMessage = vm.method.getMessage()
                        }
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = nil
        }
        .onDisappear {
            BackSwipeManager.shared.updatePopGesture(true)
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
//    ExerciseRecordView(exercise: .baseball, selectedDate: .constant(nil))
//        .environmentObject(Coordinator())
//        .environmentObject(MainSheetViewModel())
    
    NavigationStack {
        ExerciseRecordView(exerciseInfo: ExerciseResponse(base: .init(id: "123", type: "EXERCISE", recordDate: [], recordTime: [], createdAt: [], updatedAt: []), exerciseType: "BASEBALL", dailyNote: "hello world"), selectedDate: .constant(nil))
            .environmentObject(Coordinator())
            .environmentObject(MainSheetViewModel())
    }
}

