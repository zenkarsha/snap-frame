import AppKit
import SwiftUI

@MainActor
enum ExportRenderer {
    static func defaultFilename(for date: Date = Date(), timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"

        return "snapframe-\(formatter.string(from: date)).png"
    }

    static func pngData(image: NSImage, settings: FrameSettings) -> Data? {
        let canvasSize = settings.canvasSize(imageSize: image.size)
        let renderer = ImageRenderer(content: FramePreviewView(image: image, settings: settings))
        renderer.proposedSize = ProposedViewSize(canvasSize)
        renderer.scale = 1

        guard let cgImage = renderer.cgImage else {
            return nil
        }

        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        return bitmap.representation(using: .png, properties: [:])
    }

    static func savePNG(image: NSImage, settings: FrameSettings) {
        guard let data = pngData(image: image, settings: settings) else {
            NSSound.beep()
            return
        }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = defaultFilename()

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        do {
            try data.write(to: url, options: .atomic)
        } catch {
            NSSound.beep()
        }
    }
}
