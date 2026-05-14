import AppKit
import Foundation

enum MacBackgroundImageCache {
    private static let images: [MacBackgroundPreset: NSImage] = {
        Dictionary(uniqueKeysWithValues: MacBackgroundPreset.allCases.compactMap { preset in
            guard let image = loadImage(for: preset) else {
                return nil
            }

            return (preset, image)
        })
    }()

    static func image(for preset: MacBackgroundPreset) -> NSImage? {
        images[preset]
    }

    private static func loadImage(for preset: MacBackgroundPreset) -> NSImage? {
        let name = preset.resourceName

        if let url = Bundle.main.url(forResource: name, withExtension: "jpg", subdirectory: "Backgrounds") {
            return NSImage(contentsOf: url)
        }

        if let url = Bundle.main.url(forResource: name, withExtension: "jpg") {
            return NSImage(contentsOf: url)
        }

        return nil
    }
}
