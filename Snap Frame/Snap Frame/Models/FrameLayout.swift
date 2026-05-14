import CoreGraphics

struct FrameLayout: Equatable {
    let canvasSize: CGSize
    let insetRect: CGRect
    let imageRect: CGRect

    static func calculate(settings: FrameSettings, imageSize: CGSize?) -> FrameLayout {
        let canvasSize = settings.canvasSize(imageSize: imageSize)
        let maxPadding = max(0, min(canvasSize.width, canvasSize.height) / 2 - 1)
        let outerPadding = min(max(0, settings.outerPadding), maxPadding)
        let insetPadding = min(max(0, settings.insetPadding), maxPadding)

        let contentRect = CGRect(
            x: outerPadding,
            y: outerPadding,
            width: max(1, canvasSize.width - outerPadding * 2),
            height: max(1, canvasSize.height - outerPadding * 2)
        )

        let availableRect = contentRect.insetBy(
            dx: min(insetPadding, max(0, contentRect.width / 2 - 1)),
            dy: min(insetPadding, max(0, contentRect.height / 2 - 1))
        )

        guard
            let imageSize,
            imageSize.width > 0,
            imageSize.height > 0,
            availableRect.width > 0,
            availableRect.height > 0
        else {
            return FrameLayout(canvasSize: canvasSize, insetRect: contentRect, imageRect: availableRect)
        }

        let scale = min(availableRect.width / imageSize.width, availableRect.height / imageSize.height)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let origin = CGPoint(
            x: availableRect.midX - size.width / 2,
            y: availableRect.midY - size.height / 2
        )

        let imageRect = CGRect(origin: origin, size: size)
        let insetRect = imageRect
            .insetBy(dx: -insetPadding, dy: -insetPadding)
            .intersection(contentRect)

        return FrameLayout(canvasSize: canvasSize, insetRect: insetRect, imageRect: imageRect)
    }
}
