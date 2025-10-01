import SwiftUI
import PhotosUI

struct DayRecordView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @StateObject private var vm: ViewModel
    @FocusState private var isFocused: Field?
    @State private var isEditing: Bool

    init(emotion: EmotionObj) {
        _vm = StateObject(wrappedValue: ViewModel(emotion: emotion))
        self.isEditing = false
    }
    
    init(dailyInfo: DailyResponse) {
        var component = DateComponents(
            year: dailyInfo.recordDate[0],
            month: dailyInfo.recordDate[1],
            day: dailyInfo.recordDate[2],
            hour: dailyInfo.recordTime[0],
            minute: dailyInfo.recordTime[1]
        )
        component.calendar = Calendar.current
        
        _vm = StateObject(
            wrappedValue: ViewModel(
                recordId: dailyInfo.id,
                emotion: EmotionObj.matchingEmotion(dailyInfo.emotion),
                text: dailyInfo.content,
                serverImageUrls: dailyInfo.imageUrls.map { image in
                    guard let url = URL(string: image) else { return URL.currentDirectory() }
                    return url
                },
                date: component.date ?? .now
            )
        )
        self.isEditing = true
    }
    
    var body: some View {
        NavigationStack {
            content
                .task {
                    if isEditing {
                        await vm.receivedImages()
                    }
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
                    bottomImages()
                    Spacer()
                }
            }
            .scrollIndicators(.hidden)
            RecordButton(
                isEditing: $isEditing,
                text: $vm.text
            ) {
                    guard !vm.text.isEmpty else { return }
                    
                    let success = await vm.submitDailyRecord(isEditing: $isEditing)
                    if success {
                        coordinator.dismissScreen()
                    }
                    sheetVM.visibleToast = success
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
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .padding(.horizontal)
        .padding(.top, 10)
        .navigationBarBackButtonHidden()
        .navigationTitle("하루 기록")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $vm.sheet) {
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
                DismissAlertView(isDismiss: $vm.isDismiss, isEditing: $isEditing)
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
    
    // TODO: 이미지 사진들 들어가는 뷰
    private func bottomImages() -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                if vm.selectedImages.count > 0 {
                    ForEach(vm.selectedImages,  id: \.id) { photo in
                        ZStack {
                            Image(uiImage: photo.image)
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(maxWidth: 100, maxHeight: 100)
                        .clipShape(.rect(cornerRadius: 8))
                        .overlay(alignment: .topTrailing) {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 20, height: 20)
                                
                                Image("xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 7, height: 7)
                            }
                            .offset(x: 7, y: -7)
                            .onTapGesture {
                                Task { @MainActor in
                                    // 먼저 selectedImages에서 해당 photo를 찾아서 인덱스를 구함
                                    if let photoIndex = vm.selectedImages.firstIndex(where: { $0.id == photo.id }) {
                                        vm.selectedImages.remove(at: photoIndex)
                                        
                                        if photoIndex < vm.selectedItems.count {
                                            vm.selectedItems.remove(at: photoIndex)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if vm.selectedImages.count < 3 {
                    PhotosPicker(
                        selection: $vm.selectedItems,
                        maxSelectionCount: 3,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.Gray._100())
                            
                            VStack(spacing: 6) {
                                Image(systemName: "camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 30, maxHeight: 30)
                                Text("+ 사진 올리기")
                                    .typography(.p12Medium)
                            }
                            .foregroundStyle(Color.Gray._400())
                            .padding(.vertical, 23)
                            .padding(.horizontal, 17)
                        }
                        .frame(maxWidth: 100, maxHeight: 100)
                    }
                }
                
                Spacer()
            }
            .onChange(of: vm.selectedItems) {
                isFocused = nil
                Task {
                    var newImages: [PhotoTransfer] = []
                    for item in vm.selectedItems {
                        do {
                            if let image = try await item.loadTransferable(type: PhotoTransfer.self) {
                                newImages.append(image)
                            }
                        } catch {
                            debugPrint("photo loading error: \(error)")
                        }
                    }
                    
                    await MainActor.run {
                        vm.selectedImages = newImages
                    }
                }
            }
            
            Text("*최대 3장 가능")
                .typography(.p14Regular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.Gray._400())
        }
    }
}

#Preview {
    DayRecordView(emotion: .angry)
        .environmentObject(Coordinator())
}
