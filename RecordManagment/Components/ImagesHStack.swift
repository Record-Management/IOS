import SwiftUI
import PhotosUI

struct ImagesHStack: View {
    @Binding var selectedImages: [PhotoTransfer]
    @Binding var selectedItems: [PhotosPickerItem]
    var isFocused: FocusState<Field?>.Binding
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                if selectedImages.count > 0 {
                    ForEach(selectedImages,  id: \.id) { photo in
                        ZStack {
                            Image(uiImage: photo.image)
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(minWidth: 100, maxWidth: 100 ,minHeight: 100, maxHeight: 100)
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
            .onChange(of: selectedItems) {
                isFocused.wrappedValue = nil
                Task {
                    var newImages: [PhotoTransfer] = []
                    for item in selectedItems {
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
