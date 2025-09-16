import SwiftUI
import PhotosUI

struct DayRecordView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var text: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [PhotoTransfer] = []
    @State private var isDismiss: Bool = false
    @State private var sheet: Bool = false
    @FocusState private var isFocused: Bool
    let emotion: EmotionObj
    let date: Date = .now
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 24) {
                        headerView(date)
                        middleTextView()
                        bottomImages()
                        Spacer()
                    }
                }
                .scrollIndicators(.hidden)
                VStack {
                    Text("작성하기")
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(text.isEmpty ? Color.Primary.lighter() : Color.Primary.main())
                        .foregroundColor(text.isEmpty ? Color.Primary.light() : .white)
                        .cornerRadius(8)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .padding(.horizontal)
            .padding(.top, 10)
            .navigationBarBackButtonHidden()
            .navigationTitle("하루 기록")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $sheet) {
                    NavigationStack {
                        VStack {
                            EmotionView() {
                                sheet = false
                            }
                            .navigationTitle("감정 선택")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .scaledToFit()
                                        .onTapGesture {
                                            withAnimation(.interactiveSpring) {
                                                sheet = false
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
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            withAnimation(.interactiveSpring) {
                                isDismiss = true
                            }
                        }
                }
            }
            .overlay {
                if isDismiss {
                    ZStack {
                        Color(hex: "#222222").opacity(0.5)
                            .ignoresSafeArea()
                        
                        VStack {
                            Text("기록을 남기지 않고 나가실까요?")
                                .typography(.p16SemiBold)
                                .padding(.bottom,8)
                            Text("작성 중인 기록은 저장되지 않아요.")
                                .typography(.p14Regular)
                                .padding(.bottom, 16)
                            HStack(spacing: 10) {
                                Text("나가기")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.Gray._100())
                                    .foregroundStyle(Color.Gray._400())
                                    .clipShape(.rect(cornerRadius: 8))
                                    .onTapGesture {
                                        isDismiss = false
                                        coordinator.dismissScreen()
                                    }
                                Text("작성하기")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.Primary.main())
                                    .foregroundStyle(.white)
                                    .clipShape(.rect(cornerRadius: 8))
                                    .onTapGesture {
                                        isDismiss = false
                                    }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 52)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .padding(.horizontal, 32)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
        }
        
    }
    
    // TODO: Header 뷰
    private func headerView(_ date: Date) -> some View {
        HStack(spacing: 0) {
            Image(emotion.id)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 80, maxHeight: 80)
                .padding(.trailing)
                .onTapGesture {
                    sheet = true
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
    
    // TODO: 텍스트 필드 뷰
    private func middleTextView() -> some View {
        
        return VStack(alignment: .leading) {
            TextField("나의 하루는 어땠나요?",text: $text, axis: .vertical)
                .font(.system(size: 16, weight: .regular))
                .focused($isFocused)
                .lineSpacing(8)
                .tracking(0)
                .padding([.top, .trailing, .leading], 14)
                .padding(.bottom, 10)
                .onChange(of: text) { val in
                    if val.count > 1000 {
                        text = String(val.prefix(1000))
                    }
                }
            
            Spacer()
            
            Text("\(text.count) / 1000")
                .typography(.p16Regular)
                .foregroundColor(isFocused ? Color.Gray._800() : Color.Gray._500())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
        }
        .frame(minHeight: 270, maxHeight: 270)
        .background(Color.Gray._100())
        .onTapGesture {
            isFocused = true
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        
    }
    
    // TODO: 이미지 사진들 들어가는 뷰
    private func bottomImages() -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                if selectedImages.count > 0 {
                    ForEach(selectedImages,  id: \.id) { photo in
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
                                    if let photoIndex = selectedImages.firstIndex(where: { $0.id == photo.id }) {
                                        selectedImages.remove(at: photoIndex)
                                        
                                        if photoIndex < selectedItems.count {
                                            selectedItems.remove(at: photoIndex)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if selectedImages.count < 3 {
                    PhotosPicker(
                        selection: $selectedItems,
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
            .onChange(of: selectedItems) { items in
                isFocused = false
                Task {
                    var newImages: [PhotoTransfer] = []
                    for item in items {
                        do {
                            if let image = try await item.loadTransferable(type: PhotoTransfer.self) {
                                newImages.append(image)
                            }
                        } catch {
                            debugPrint("photo loading error: \(error)")
                        }
                    }
                    
                    await MainActor.run {
                        selectedImages = newImages
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
}
