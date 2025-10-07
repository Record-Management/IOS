import SwiftUI
import PhotosUI

struct PhotoTransfer: Transferable, Identifiable, Hashable {
    let image: UIImage
    let id: UUID = UUID()
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else {
                throw NSError(domain: "InVaild Image", code: 0)
            }
            return PhotoTransfer(image: image)
        }
    }
}
