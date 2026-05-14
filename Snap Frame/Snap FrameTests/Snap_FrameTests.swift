//
//  Snap_FrameTests.swift
//  Snap FrameTests
//
//  Created by master on 2026/5/13.
//

import AppKit
import CoreGraphics
import Testing
@testable import Snap_Frame

@Suite(.serialized)
struct Snap_FrameTests {

    @Test func ratioCalculatesCanvasSize() {
        let wide = FrameRatio.wide16x9.canvasSize(width: 1600)
        #expect(wide.width == 1600)
        #expect(wide.height == 900)

        let classic = FrameRatio.landscape4x3.canvasSize(width: 1600)
        #expect(classic.width == 1600)
        #expect(classic.height == 1200)
    }

    @Test func autoRatioUsesImageSizeOrFallback() {
        let auto = FrameRatio.auto.canvasSize(width: 1600, imageSize: CGSize(width: 3000, height: 2000))
        #expect(auto.width == 1600)
        #expect(auto.height == 1600 / 1.5)

        let fallback = FrameRatio.auto.canvasSize(width: 1600)
        #expect(fallback.width == 1600)
        #expect(fallback.height == 1200)
    }

    @Test func layoutAppliesOuterAndInsetPadding() {
        let settings = FrameSettings(
            ratio: .square,
            outputWidth: 1000,
            outerPadding: 100,
            insetPadding: 50,
            cornerRadius: 20,
            shadow: 10,
            backgroundHex: "#000000"
        )

        let layout = FrameLayout.calculate(settings: settings, imageSize: nil)

        #expect(layout.canvasSize == CGSize(width: 1000, height: 1000))
        #expect(layout.insetRect == CGRect(x: 100, y: 100, width: 800, height: 800))
        #expect(layout.imageRect == CGRect(x: 150, y: 150, width: 700, height: 700))
    }

    @Test func containFitCentersImageWithoutCropping() {
        let settings = FrameSettings(
            ratio: .square,
            outputWidth: 1000,
            outerPadding: 100,
            insetPadding: 50,
            cornerRadius: 20,
            shadow: 10,
            backgroundHex: "#000000"
        )

        let layout = FrameLayout.calculate(settings: settings, imageSize: CGSize(width: 1200, height: 600))

        #expect(layout.imageRect.width == 700)
        #expect(layout.imageRect.height == 350)
        #expect(layout.imageRect.origin.x == 150)
        #expect(layout.imageRect.origin.y == 325)
        #expect(layout.insetRect == CGRect(x: 100, y: 275, width: 800, height: 450))
    }

    @Test func autoLayoutKeepsEqualOuterPaddingAroundScreenshotFrame() {
        let settings = FrameSettings(
            ratio: .auto,
            outputWidth: 1000,
            outerPadding: 100,
            insetPadding: 50,
            cornerRadius: 20,
            shadow: 10,
            backgroundHex: "#000000"
        )

        let layout = FrameLayout.calculate(settings: settings, imageSize: CGSize(width: 1200, height: 600))

        #expect(layout.canvasSize == CGSize(width: 1000, height: 650))
        #expect(layout.insetRect == CGRect(x: 100, y: 100, width: 800, height: 450))
        #expect(layout.imageRect == CGRect(x: 150, y: 150, width: 700, height: 350))
    }

    @Test func layoutClampsNegativeAndOversizedPadding() {
        let negativeSettings = FrameSettings(
            ratio: .square,
            outputWidth: 400,
            outerPadding: -100,
            insetPadding: -20,
            cornerRadius: 0,
            shadow: 0
        )

        let negativeLayout = FrameLayout.calculate(settings: negativeSettings, imageSize: nil)
        #expect(negativeLayout.canvasSize == CGSize(width: 400, height: 400))
        #expect(negativeLayout.insetRect == CGRect(x: 0, y: 0, width: 400, height: 400))
        #expect(negativeLayout.imageRect == CGRect(x: 0, y: 0, width: 400, height: 400))

        let oversizedSettings = FrameSettings(
            ratio: .square,
            outputWidth: 400,
            outerPadding: 300,
            insetPadding: 300,
            cornerRadius: 0,
            shadow: 0
        )

        let oversizedLayout = FrameLayout.calculate(settings: oversizedSettings, imageSize: nil)
        #expect(oversizedLayout.insetRect == CGRect(x: 199, y: 199, width: 2, height: 2))
        #expect(oversizedLayout.imageRect == CGRect(x: 199, y: 199, width: 2, height: 2))
    }

    @Test func autoCanvasSizeIgnoresInvalidImageSize() {
        let settings = FrameSettings(
            ratio: .auto,
            outputWidth: 1200,
            outerPadding: 100,
            insetPadding: 50,
            cornerRadius: 0,
            shadow: 0
        )

        #expect(settings.canvasSize(imageSize: CGSize(width: 0, height: 600)) == CGSize(width: 1200, height: 900))
        #expect(settings.canvasSize(imageSize: CGSize(width: 600, height: -1)) == CGSize(width: 1200, height: 900))
    }

    @Test func frameSettingsRoundTripCodable() {
        let settings = FrameSettings(
            ratio: .landscape3x2,
            outputWidth: 1800,
            outerPadding: 160,
            insetPadding: 20,
            cornerRadius: 24,
            shadow: 36,
            backgroundHex: "#FFAA00",
            insetColorHex: "#101010",
            usesDetectedInsetColor: false,
            backgroundPreset: .sky
        )

        let decoded = FrameSettings.decode(from: settings.encodedString())
        #expect(decoded == settings)
    }

    @Test func frameSettingsDecodeUsesDefaultsForMissingModernKeys() throws {
        let data = """
        {
          "ratio": "wide16x9",
          "outputWidth": 1440,
          "outerPadding": 96,
          "insetPadding": 18,
          "cornerRadius": 12,
          "shadow": 22,
          "backgroundHex": "#ABCDEF"
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(FrameSettings.self, from: data)

        #expect(decoded.ratio == .wide16x9)
        #expect(decoded.outputWidth == 1440)
        #expect(decoded.outerPadding == 96)
        #expect(decoded.insetPadding == 18)
        #expect(decoded.cornerRadius == 12)
        #expect(decoded.shadow == 22)
        #expect(decoded.backgroundHex == "#ABCDEF")
        #expect(decoded.insetColorHex == FrameSettings.default.insetColorHex)
        #expect(decoded.usesDetectedInsetColor == FrameSettings.default.usesDetectedInsetColor)
        #expect(decoded.backgroundKind == FrameSettings.default.backgroundKind)
        #expect(decoded.backgroundPreset == FrameSettings.default.backgroundPreset)
        #expect(decoded.macBackgroundPreset == FrameSettings.default.macBackgroundPreset)
        #expect(decoded.solidBackgroundPreset == FrameSettings.default.solidBackgroundPreset)
        #expect(decoded.customGradientStartHex == FrameSettings.default.customGradientStartHex)
        #expect(decoded.customGradientEndHex == FrameSettings.default.customGradientEndHex)
        #expect(decoded.customGradientDirection == FrameSettings.default.customGradientDirection)
    }

    @Test func frameSettingsDecodeFallsBackToDefaultForInvalidJSON() {
        #expect(FrameSettings.decode(from: "{") == .default)
    }

    @Test func solidBackgroundPresetMigratesOldNames() throws {
        let oldNames = [
            "paper": SolidBackgroundPreset.azure,
            "sage": SolidBackgroundPreset.coral,
            "clay": SolidBackgroundPreset.amber,
        ]

        for (oldName, expectedPreset) in oldNames {
            let decoded = try JSONDecoder().decode(SolidBackgroundPreset.self, from: "\"\(oldName)\"".data(using: .utf8)!)
            #expect(decoded == expectedPreset)
        }
    }

    @MainActor
    @Test func exportDefaultFilenameUsesTimestamp() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let date = calendar.date(from: DateComponents(
            year: 2026,
            month: 5,
            day: 13,
            hour: 18,
            minute: 20,
            second: 14
        ))!

        #expect(ExportRenderer.defaultFilename(for: date, timeZone: calendar.timeZone) == "snapframe-2026-05-13 at 18.20.14.png")
    }

    @MainActor
    @Test func exportRendererProducesPNGData() throws {
        let image = testImage(size: CGSize(width: 320, height: 180), color: .systemBlue)
        let settings = FrameSettings(
            ratio: .wide16x9,
            outputWidth: 640,
            outerPadding: 40,
            insetPadding: 12,
            cornerRadius: 8,
            shadow: 0,
            backgroundKind: .solid,
            solidBackgroundPreset: .ink
        )

        let data = try #require(ExportRenderer.pngData(image: image, settings: settings))
        #expect(data.starts(with: [0x89, 0x50, 0x4E, 0x47]))
        #expect(NSImage(data: data)?.size == CGSize(width: 640, height: 360))
    }

    @Test func insetColorDetectionUsesDominantEdgeColor() throws {
        let image = NSImage(size: CGSize(width: 400, height: 260))
        image.lockFocus()

        NSColor(calibratedRed: 0.13, green: 0.14, blue: 0.15, alpha: 1).setFill()
        NSBezierPath(rect: CGRect(x: 0, y: 0, width: 400, height: 260)).fill()

        NSColor.white.setFill()
        NSBezierPath(rect: CGRect(x: 160, y: 220, width: 80, height: 16)).fill()
        NSBezierPath(rect: CGRect(x: 360, y: 96, width: 16, height: 64)).fill()

        image.unlockFocus()

        let detectedHex = try #require(ImageColorSampler.detectedBackgroundHex(from: image))
        let detected = try #require(rgbComponents(from: detectedHex))

        #expect(abs(detected.red - 33) <= 20)
        #expect(abs(detected.green - 35) <= 20)
        #expect(abs(detected.blue - 38) <= 20)
        #expect(detected.red < 90)
        #expect(detected.green < 90)
        #expect(detected.blue < 90)
    }

    @Test func insetColorDetectionReturnsNilForEmptyImage() {
        #expect(ImageColorSampler.detectedBackgroundHex(from: NSImage()) == nil)
    }

    @Test func documentStateStoresImageAndSize() {
        let image = testImage(size: CGSize(width: 42, height: 24), color: .systemRed)
        var state = ImageFrameDocumentState.empty

        state.setImage(image)

        #expect(state.image === image)
        #expect(state.imageSize == CGSize(width: 42, height: 24))
        #expect(state.settings == .default)
    }

    private func testImage(size: CGSize, color: NSColor) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        NSBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        image.unlockFocus()
        return image
    }

    private func rgbComponents(from hex: String) -> (red: Int, green: Int, blue: Int)? {
        var value = hex
        if value.hasPrefix("#") {
            value.removeFirst()
        }

        guard value.count == 6, let rgb = Int(value, radix: 16) else {
            return nil
        }

        return (
            red: (rgb & 0xFF0000) >> 16,
            green: (rgb & 0x00FF00) >> 8,
            blue: rgb & 0x0000FF
        )
    }
}
