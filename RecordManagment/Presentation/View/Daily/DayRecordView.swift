import SwiftUI
import PhotosUI

struct DayRecordView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @StateObject private var vm: ViewModel
    @FocusState private var isFocused: Field?

    init(emotion: EmotionObj) {
        _vm = StateObject(wrappedValue: ViewModel(
            emotion: emotion,
            recordUseCase: RecordUseCase(
                repository: DefaultRecordRepository()
            ),
            imageUseCase: ImageUseCase(
                repository: DefaultImageRepository()
            ),
            method: .create
        ))
    }
    
    init(dailyInfo: DailyResponse) {
        var component = DateComponents(
            year: dailyInfo.base.recordDate[0],
            month: dailyInfo.base.recordDate[1],
            day: dailyInfo.base.recordDate[2],
            hour: dailyInfo.base.recordTime[0],
            minute: dailyInfo.base.recordTime[1]
        )
        component.calendar = Calendar.current
        
        _vm = StateObject(
            wrappedValue: ViewModel(
                recordId: dailyInfo.base.id,
                emotion: EmotionObj.matchingEmotion(dailyInfo.emotion),
                text: dailyInfo.content,
                serverImageUrls: dailyInfo.imageUrls.map { image in
                    guard let url = URL(string: image) else { return URL.currentDirectory() }
                    return url
                },
                date: component.date ?? .now,
                recordUseCase: RecordUseCase(
                    repository: DefaultRecordRepository()
                ),
                imageUseCase: ImageUseCase(
                    repository: DefaultImageRepository()
                ),
                method: .update
            )
        )
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
    
    @ViewBuilder
    private var content: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerView(vm.date)
                    MultiTextField(text: $vm.text, isFocused: $isFocused)
                    ImagesHStack(selectedImages: $vm.selectedImages, selectedItems: $vm.selectedItems, isFocused: $isFocused)
                    Spacer()
                }
            }
            .scrollIndicators(.hidden)
            RecordButton(
                method: $vm.method,
                text: $vm.text
            ) {
                guard !vm.text.isEmpty else { return }
                    
                let success = await vm.submitDailyRecord(method: $vm.method)
                    
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
        .padding(.top, 10)
        .navigationBarBackButtonHidden()
        .navigationTitle("하루 기록")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $vm.sheet) {
            emotionReSelectionView
        }
        .toolbar {
            if vm.method == .update || vm.method == .delete {
                ToolbarItem(placement: .topBarLeading) {
                      Button(action: {
                          vm.isDismiss = true
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
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = nil
        }
    }
    
    // TODO: Header 뷰
    private func headerView(_ date: Date) -> some View {
        HStack(spacing: 0) {
            Image(vm.emotion.id)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 80, maxHeight: 80)
                .padding(.trailing)
                .onTapGesture {
                    vm.sheet = true
                }
            VStack(alignment: .leading, spacing: 3) {
                Group {
                    Text(Date.dailyRecordDateFormat(date))
                        .typography(.p16SemiBold)
                    Text(Date.dailyTimeRecordDateFormat(date))
                        .typography(.p16Medium)
                }
                .foregroundStyle(Color.Gray._900())
            }
            
            Spacer()
        }
    }
    
    // TODO: 감정 재선택 뷰
    private var emotionReSelectionView: some View {
        NavigationStack {
            VStack {
                EmotionView(isFullScreen: false) { emotion in
                    vm.emotion = emotion
                    vm.sheet = false
                }
                .navigationTitle("감정 선택")
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
    DayRecordView(emotion: .angry)
        .environmentObject(Coordinator())
}
