import SwiftUI

struct HabitRecordView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @EnvironmentObject var recordVM: RecordViewModel
    @EnvironmentObject var selectionVM: RecordSelectionView.ViewModel
    @StateObject var vm: ViewModel
    @FocusState var isFocused: Field?
    @GestureState private var isDetectingLongPress: Bool = false
    
    init(habit: HabitObj) {
        _vm = StateObject(wrappedValue: ViewModel(
            habit: habit,
            method: .create,
            useCase: HabitRecordUseCase(
                repository: DefaultHabitRecordRepository()
            ),
        ))
    }
    
    init(habitInfo: HabitResponse) {
        _vm = StateObject(wrappedValue: .init(
            habitInfo: habitInfo,
            method: .update,
            useCase: HabitRecordUseCase(
                repository: DefaultHabitRecordRepository()
            ))
        )
    }
    
    var body: some View {
        if vm.method == .create {
            NavigationStack {
                content
                    .onAppear {
                        vm.currentMainRecord = recordVM.changeMainRecordPossible()
                    }
                    .showMainRecordAlertView(isAlert: $vm.isMainRecordToggle, action: {
                        vm.isMainRecord = vm.isMainRecordToggle
                    })
            }
        } else {
            content
        }
    }
    
    var content: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(vm.habit.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100, maxHeight: 100)
                        .onTapGesture {
                            vm.sheet = true
                        }
                    Text(vm.habit.getName())
                        .typography(.p16SemiBold)
                    
                    if vm.currentMainRecord && selectionVM.originalRecord == .habit {
                        HStack(spacing: 6) {
                            Image("PinToggle")
                            Text("메인 기록으로 변경")
                                .typography(.p16SemiBold)
                            Spacer()
                            Toggle("", isOn: $vm.isMainRecordToggle)
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack(spacing: 6) {
                        Image("Notification")
                        Text("알림")
                            .typography(.p16SemiBold)
                        Spacer()
                        Toggle("", isOn: $vm.isToggle)
                    }
                    .padding(.horizontal)
                    
                    if vm.isToggle {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.Gray._100(), lineWidth: 1)
                            Text(Date.dailyTimeRecordDateFormat(vm.time))
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .onDisappear {
                                    vm.isOnDatePicker = false
                                }
                        }
                        .padding(.bottom, vm.isOnDatePicker ? -14 : 0)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.isOnDatePicker.toggle()
                        }
                    }
                    
                    if vm.isOnDatePicker {
                        VStack(alignment: .trailing) {
                            DatePicker(
                                "", // 라벨 텍스트를 빈 문자열로
                                selection: $vm.time,
                                displayedComponents: [.hourAndMinute] // 날짜만 선택
                            )
                            .datePickerStyle(.wheel)  // Wheel 스타일
                            .labelsHidden()           // 라벨 숨김
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 28, weight: .bold))
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                            .clipped()
                            Text("확인")
                                .typography(.p16SemiBold)
                                .onTapGesture {
                                    vm.isOnDatePicker.toggle()
                                }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider().background(Color.Gray._200()).padding(.horizontal)
                    VStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image("memo")
                            Text("메모")
                            Spacer()
                        }
                        
                        MultiTextField(placeholder: "메모",text: $vm.memo, isFocused: $isFocused)
                    }
                    .padding(.horizontal)
                }
            }
            .scrollIndicators(.hidden)
            
            RecordButton(method: .constant(vm.method), condition: .constant(true)) {
                var success: Bool = false
                
                if vm.method == .create {
                    success = await vm.create(current: .now)
                } else if vm.method == .update {
                    success = await vm.update()
                }
                    
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
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationTitle("습관 기록")
        .sheet(isPresented: $vm.sheet) {
            habitReSelectionView
        }
        .contentShape(Rectangle())
        .onDisappear {
            BackSwipeManager.shared.updatePopGesture(true)
        }
        .toolbar {
            if vm.method == .update || vm.method == .delete {
                ToolbarItem(placement: .topBarLeading) {
                      Button(action: {
                        coordinator.pop()
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
                        let success = await vm.delete()
                        vm.isDismiss = false
                        if success {
                            if vm.method == .delete {
                                coordinator.pop()
                            }
                            sheetVM.visibleToast = success
                            sheetVM.toastMessage = vm.method.getMessage()
                        }
                    }
                }
            }
        }
        .onTapGesture {
            isFocused = nil
        }
    }
    
    // TODO: Exercise ReSelection View
    private var habitReSelectionView: some View {
        NavigationStack {
            VStack {
                HabitListView(title: "습관 재선택") { habit in
                    vm.habit = habit
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
    NavigationStack {
        HabitRecordView(
            habit: .drinking
        )
        .environmentObject(Coordinator())
        .environmentObject(MainSheetViewModel(
            useCase: MainSheetUseCase(
                repository: DefaultMainSheetRepository()
            )
        ))
        .environmentObject(RecordViewModel(useCase: RecordUseCase(repository: DefaultRecordRepository())))
    }
}
