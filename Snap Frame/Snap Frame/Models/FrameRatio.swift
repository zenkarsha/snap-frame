import CoreGraphics

enum FrameRatio: String, CaseIterable, Codable, Equatable, Identifiable {
    case auto
    case landscape3x2
    case landscape4x3
    case wide16x9
    case square

    var id: String { rawValue }

    var title: String {
        switch self {
        case .auto:
            "Auto"
        case .landscape3x2:
            "3:2"
        case .landscape4x3:
            "4:3"
        case .wide16x9:
            "16:9"
        case .square:
            "1:1"
        }
    }

    func aspectRatio(imageSize: CGSize?) -> CGFloat {
        switch self {
        case .auto:
            guard let imageSize, imageSize.width > 0, imageSize.height > 0 else {
                return 4 / 3
            }

            return imageSize.width / imageSize.height
        case .landscape3x2:
            return 3 / 2
        case .landscape4x3:
            return 4 / 3
        case .wide16x9:
            return 16 / 9
        case .square:
            return 1
        }
    }

    func canvasSize(width: CGFloat, imageSize: CGSize? = nil) -> CGSize {
        CGSize(width: width, height: width / aspectRatio(imageSize: imageSize))
    }
}
