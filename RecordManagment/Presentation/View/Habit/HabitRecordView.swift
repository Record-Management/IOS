//
//  HabitRecordView.swift
//  RecordManagment
//
//  Created by 김용해 on 10/15/25.
//

import SwiftUI

struct HabitRecordView: View {
    @Binding var selectedDate: Date?
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @StateObject var vm: ViewModel
    @FocusState var isFocused: Field?
    @State var isToggle: Bool = false
    @State var date: Date = Calendar.current.date(from: DateComponents(
        year: Calendar.current.component(.year, from: .now),
        month: Calendar.current.component(.month, from: .now),
        day: Calendar.current.component(.day, from: .now),
        hour: 10,
        minute: 0
    )) ?? .now
    @State var isOnDatePicker: Bool = false
    
    init(habit: HabitObj ,selectedDate: Binding<Date?>) {
        self._selectedDate = selectedDate
        _vm = StateObject(wrappedValue: ViewModel(
            habit: habit,
            method: .create
        ))
    }
    
    var body: some View {
        if vm.method == .create {
            NavigationStack {
                content
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
                    HStack(spacing: 6) {
                        Image("Notification")
                        Text("알림")
                            .typography(.p16SemiBold)
                        Spacer()
                        Toggle("", isOn: $isToggle)
                    }
                    
                    if isToggle {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.Gray._100(), lineWidth: 1)
                            Text(Date.dailyTimeRecordDateFormat(date))
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .onTapGesture {
                                    isOnDatePicker.toggle()
                                }
                                .onDisappear {
                                    isOnDatePicker = false
                                }
                        }
                        .padding(.bottom, isOnDatePicker ? -14 : 0)
                    }
                    
                    if isOnDatePicker {
                        VStack(alignment: .trailing) {
                            DatePicker(
                                "", // 라벨 텍스트를 빈 문자열로
                                selection: $date,
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
                                    isOnDatePicker.toggle()
                                }
                        }
                    }
                    
                    Divider().background(Color.Gray._200())
                    VStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image("memo")
                            Text("메모")
                            Spacer()
                        }
                        
                        MultiTextField(placeholder: "메모",text: $vm.memo, isFocused: $isFocused)
                    }
                }
            }
            .scrollIndicators(.hidden)
            RecordButton(method: .constant(.create), condition: .constant(true)) {
                
            }
        }
        .padding(.horizontal)
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
                    
                }
            }
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
            habit: .drinking, selectedDate: .constant(.now)
        )
        .environmentObject(Coordinator())
        .environmentObject(MainSheetViewModel())
    }
}
