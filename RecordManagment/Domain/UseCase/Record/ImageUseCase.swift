import Foundation
import UIKit

protocol ImageUseCase {
    func getImage(_ url: URL) async -> Data
    /// 신규 로컬 이미지를 업로드하고, 기존 이미지 URL과 병합하여 최종 URL 리스트를 반환합니다.
    func uploadAndMergeImages(selectedImages: [PhotoTransfer]) async throws -> [String]
}

struct DefaultImageUseCase: ImageUseCase {
    private let repository: ImageRepository
    
    init(repository: ImageRepository) {
        self.repository = repository
    }
    
    func getImage(_ url: URL) async -> Data {
        do {
            return try await repository.fetch(url)
        } catch {
            Log.error("Image fetch failed: \(error.localizedDescription)")
            return Data()
        }
    }
    
    func uploadAndMergeImages(selectedImages: [PhotoTransfer]) async throws -> [String] {
        var finalImageUrls: [String] = []
        var newLocalImageDatas: [Data?] = []
        
        // 1. 기존 이미지 URL 수집 및 신규 로컬 이미지(UIImage) -> Data 변환
        for photo in selectedImages {
            if let serverUrl = photo.serverUrl {
                finalImageUrls.append(serverUrl)
            } else if let data = photo.image.jpegData(compressionQuality: 0.8) {
                newLocalImageDatas.append(data)
            }
        }
        
        // 2. 새로 추가할 이미지가 존재한다면 서버에 일괄 업로드 진행
        if !newLocalImageDatas.isEmpty {
            let uploadedUrls = try await repository.upload(files: newLocalImageDatas)
            finalImageUrls.append(contentsOf: uploadedUrls)
        }
        
        return finalImageUrls
    }
}
