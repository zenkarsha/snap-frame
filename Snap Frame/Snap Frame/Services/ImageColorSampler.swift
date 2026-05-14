import AppKit

enum ImageColorSampler {
    static func detectedBackgroundHex(from image: NSImage) -> String? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        let sampleSize = 128
        let width = sampleSize
        let height = sampleSize
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        let didDrawImage = pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return false
            }

            context.interpolationQuality = .low
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }

        guard didDrawImage else {
            return nil
        }

        let sampledPixels = sampledEdgePixels(
            pixels: pixels,
            width: width,
            height: height,
            bytesPerRow: bytesPerRow,
            bytesPerPixel: bytesPerPixel
        )

        guard let color = dominantColor(from: sampledPixels) else {
            return nil
        }

        return String(format: "#%02X%02X%02X", color.red, color.green, color.blue)
    }

    private static func sampledEdgePixels(
        pixels: [UInt8],
        width: Int,
        height: Int,
        bytesPerRow: Int,
        bytesPerPixel: Int
    ) -> [RGBColor] {
        let edgeMargin = max(2, min(width, height) / 32)
        let edgeDepth = max(10, min(width, height) / 8)
        let cornerExclusion = edgeDepth * 2
        var colors: [RGBColor] = []
        colors.reserveCapacity(width * edgeDepth * 2 + height * edgeDepth * 2)

        for y in 0..<height {
            for x in 0..<width {
                let isInHorizontalSafeRange = x >= cornerExclusion && x < width - cornerExclusion
                let isInVerticalSafeRange = y >= cornerExclusion && y < height - cornerExclusion
                let isTopBand = y >= edgeMargin && y < edgeMargin + edgeDepth
                let isBottomBand = y >= height - edgeMargin - edgeDepth && y < height - edgeMargin
                let isLeftBand = x >= edgeMargin && x < edgeMargin + edgeDepth
                let isRightBand = x >= width - edgeMargin - edgeDepth && x < width - edgeMargin

                guard (isInHorizontalSafeRange && (isTopBand || isBottomBand))
                    || (isInVerticalSafeRange && (isLeftBand || isRightBand))
                else {
                    continue
                }

                let index = y * bytesPerRow + x * bytesPerPixel
                let alpha = pixels[index + 3]

                guard alpha > 220 else {
                    continue
                }

                colors.append(RGBColor(
                    red: Int(pixels[index]),
                    green: Int(pixels[index + 1]),
                    blue: Int(pixels[index + 2])
                ))
            }
        }

        return colors
    }

    private static func dominantColor(from colors: [RGBColor]) -> RGBColor? {
        guard !colors.isEmpty else {
            return nil
        }

        let bucketSize = 16
        let buckets = colors.reduce(into: [Int: ColorBucket]()) { buckets, color in
            let key = ((color.red / bucketSize) << 16) | ((color.green / bucketSize) << 8) | (color.blue / bucketSize)
            buckets[key, default: ColorBucket()].append(color)
        }

        guard let bucket = buckets.values.max(by: { lhs, rhs in
            if lhs.count == rhs.count {
                return lhs.luminanceVariance > rhs.luminanceVariance
            }

            return lhs.count < rhs.count
        }) else {
            return nil
        }

        return bucket.averageColor
    }
}

private struct RGBColor {
    let red: Int
    let green: Int
    let blue: Int
}

private struct ColorBucket {
    private(set) var count = 0
    private var redTotal = 0
    private var greenTotal = 0
    private var blueTotal = 0
    private var luminanceTotal = 0
    private var luminanceSquaredTotal = 0

    mutating func append(_ color: RGBColor) {
        let luminance = (color.red * 299 + color.green * 587 + color.blue * 114) / 1000

        count += 1
        redTotal += color.red
        greenTotal += color.green
        blueTotal += color.blue
        luminanceTotal += luminance
        luminanceSquaredTotal += luminance * luminance
    }

    var averageColor: RGBColor {
        RGBColor(
            red: redTotal / count,
            green: greenTotal / count,
            blue: blueTotal / count
        )
    }

    var luminanceVariance: Int {
        let average = luminanceTotal / count
        return luminanceSquaredTotal / count - average * average
    }
}
