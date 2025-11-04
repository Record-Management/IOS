import SwiftUI
import PhotosUI

struct PhotoTransfer: Transferable, Identifiable, Hashable {
    let id: UUID = UUID()
    let image: UIImage
    var serverUrl: String?
    
    init(image: UIImage, serverUrl: String? = nil) {
        self.image = image
        self.serverUrl = serverUrl
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else {
                throw NSError(domain: "InVaild Image", code: 0)
            }
            return PhotoTransfer(image: image)
        }
    }
}
