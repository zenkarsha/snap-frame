import AppKit

struct ImageFrameDocumentState {
    var image: NSImage?
    var imageSize: CGSize?
    var settings: FrameSettings

    static let empty = ImageFrameDocumentState(image: nil, imageSize: nil, settings: .default)

    mutating func setImage(_ image: NSImage) {
        self.image = image
        imageSize = image.size
    }
}
