import CoreGraphics
import SwiftUI

enum BackgroundPreset: String, CaseIterable, Codable, Identifiable {
    case rose
    case cool
    case beach
    case violet
    case love
    case flower
    case sky
    case dusk
    case lime
    case aurora

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rose: "Rose"
        case .cool: "Cool"
        case .beach: "Beach"
        case .violet: "Violet"
        case .love: "Love"
        case .flower: "Flower"
        case .sky: "Sky"
        case .dusk: "Dusk"
        case .lime: "Lime"
        case .aurora: "Aurora"
        }
    }

    var colors: [Color] {
        switch self {
        case .rose:
            [Color(hex: "#FF8D84")!, Color(hex: "#FFC076")!, Color(hex: "#96C7D5")!, Color(hex: "#D161B0")!]
        case .cool:
            [Color(hex: "#D8E6E2")!, Color(hex: "#B5CEC8")!, Color(hex: "#8BA9BE")!, Color(hex: "#D3BBC7")!]
        case .beach:
            [Color(hex: "#EAD6B8")!, Color(hex: "#B9C8A3")!, Color(hex: "#83B7A9")!, Color(hex: "#D19A86")!]
        case .violet:
            [Color(hex: "#CAB8D9")!, Color(hex: "#E1C3BD")!, Color(hex: "#8FA3AE")!, Color(hex: "#485D75")!]
        case .love:
            [Color(hex: "#E7A6A1")!, Color(hex: "#D27B86")!, Color(hex: "#A06E8E")!, Color(hex: "#F0D2BE")!]
        case .flower:
            [Color(hex: "#E6D7F2")!, Color(hex: "#B9A0D8")!, Color(hex: "#7E71B8")!, Color(hex: "#D8AECF")!]
        case .sky:
            [Color(hex: "#C5DDE3")!, Color(hex: "#E2D4BC")!, Color(hex: "#C4B6D5")!, Color(hex: "#86A8B6")!]
        case .dusk:
            [Color(hex: "#2C353A")!, Color(hex: "#574B5C")!, Color(hex: "#9B746B")!, Color(hex: "#D0A86F")!]
        case .lime:
            [Color(hex: "#E6DFA9")!, Color(hex: "#B7C77C")!, Color(hex: "#82A08B")!, Color(hex: "#D2C3A8")!]
        case .aurora:
            [Color(hex: "#D9E3C6")!, Color(hex: "#A7BFA4")!, Color(hex: "#7DA7A8")!, Color(hex: "#C9A6B8")!]
        }
    }
}

enum BackgroundKind: String, Codable {
    case gradient
    case mac
    case solid
    case customSolid
    case customGradient
}

enum MacBackgroundPreset: String, CaseIterable, Codable, Identifiable {
    case bigSur = "Big Sur"
    case ventura = "Ventura"
    case tahoe = "Tahoe"
    case monterey = "Monterey"
    case sequoia = "Sequoia"

    var id: String { rawValue }
    var title: String { rawValue }
    var resourceName: String { rawValue }
}

enum SolidBackgroundPreset: String, CaseIterable, Codable, Identifiable {
    case ink
    case azure
    case coral
    case amber

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ink: "Ink"
        case .azure: "Azure"
        case .coral: "Coral"
        case .amber: "Amber"
        }
    }

    var color: Color {
        switch self {
        case .ink: Color(hex: "#171717")!
        case .azure: Color(hex: "#027BFF")!
        case .coral: Color(hex: "#F46460")!
        case .amber: Color(hex: "#E8AF55")!
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        switch value {
        case "paper":
            self = .azure
        case "sage":
            self = .coral
        case "clay":
            self = .amber
        default:
            guard let preset = SolidBackgroundPreset(rawValue: value) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unknown solid background preset: \(value)"
                )
            }

            self = preset
        }
    }
}

struct FrameSettings: Codable, Equatable {
    var ratio: FrameRatio
    var outputWidth: CGFloat
    var outerPadding: CGFloat
    var insetPadding: CGFloat
    var insetColorHex: String
    var usesDetectedInsetColor: Bool
    var cornerRadius: CGFloat
    var shadow: CGFloat
    var backgroundKind: BackgroundKind
    var backgroundPreset: BackgroundPreset
    var macBackgroundPreset: MacBackgroundPreset
    var solidBackgroundPreset: SolidBackgroundPreset
    var backgroundHex: String
    var customGradientStartHex: String
    var customGradientEndHex: String
    var customGradientDirection: GradientDirection

    static let `default` = FrameSettings(
        ratio: .auto,
        outputWidth: 1600,
        outerPadding: 140,
        insetPadding: 28,
        cornerRadius: 34,
        shadow: 34,
        backgroundHex: "#FFFFFF",
        insetColorHex: "#111111",
        usesDetectedInsetColor: true,
        backgroundKind: .gradient,
        backgroundPreset: .rose,
        macBackgroundPreset: .bigSur,
        solidBackgroundPreset: .ink,
        customGradientStartHex: "#8B5CF6",
        customGradientEndHex: "#EC4899",
        customGradientDirection: .right,
    )

    var backgroundColor: Color {
        Color(hex: backgroundHex) ?? .white
    }

    var insetColor: Color {
        Color(hex: insetColorHex) ?? Color(hex: FrameSettings.default.insetColorHex)!
    }

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: backgroundPreset.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var customBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: customGradientStartHex) ?? Color(hex: FrameSettings.default.customGradientStartHex)!,
                Color(hex: customGradientEndHex) ?? Color(hex: FrameSettings.default.customGradientEndHex)!,
            ],
            startPoint: customGradientDirection.startPoint,
            endPoint: customGradientDirection.endPoint
        )
    }

    func canvasSize(imageSize: CGSize? = nil) -> CGSize {
        if
            ratio == .auto,
            let imageSize,
            imageSize.width > 0,
            imageSize.height > 0
        {
            let horizontalPadding = max(0, outerPadding) + max(0, insetPadding)
            let imageWidth = max(1, outputWidth - horizontalPadding * 2)
            let imageHeight = imageWidth / (imageSize.width / imageSize.height)

            return CGSize(width: outputWidth, height: imageHeight + horizontalPadding * 2)
        }

        return ratio.canvasSize(width: outputWidth, imageSize: imageSize)
    }
}

extension FrameSettings {
    init(
        ratio: FrameRatio,
        outputWidth: CGFloat,
        outerPadding: CGFloat,
        insetPadding: CGFloat,
        cornerRadius: CGFloat,
        shadow: CGFloat,
        backgroundHex: String = FrameSettings.default.backgroundHex,
        insetColorHex: String = FrameSettings.default.insetColorHex,
        usesDetectedInsetColor: Bool = true,
        backgroundKind: BackgroundKind = FrameSettings.default.backgroundKind,
        backgroundPreset: BackgroundPreset = FrameSettings.default.backgroundPreset,
        macBackgroundPreset: MacBackgroundPreset = FrameSettings.default.macBackgroundPreset,
        solidBackgroundPreset: SolidBackgroundPreset = FrameSettings.default.solidBackgroundPreset,
        customGradientStartHex: String = FrameSettings.default.customGradientStartHex,
        customGradientEndHex: String = FrameSettings.default.customGradientEndHex,
        customGradientDirection: GradientDirection = FrameSettings.default.customGradientDirection
    ) {
        self.ratio = ratio
        self.outputWidth = outputWidth
        self.outerPadding = outerPadding
        self.insetPadding = insetPadding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.backgroundHex = backgroundHex
        self.insetColorHex = insetColorHex
        self.usesDetectedInsetColor = usesDetectedInsetColor
        self.backgroundKind = backgroundKind
        self.backgroundPreset = backgroundPreset
        self.macBackgroundPreset = macBackgroundPreset
        self.solidBackgroundPreset = solidBackgroundPreset
        self.customGradientStartHex = customGradientStartHex
        self.customGradientEndHex = customGradientEndHex
        self.customGradientDirection = customGradientDirection
    }

    enum CodingKeys: String, CodingKey {
        case ratio
        case outputWidth
        case outerPadding
        case insetPadding
        case insetColorHex
        case usesDetectedInsetColor
        case cornerRadius
        case shadow
        case backgroundKind
        case backgroundPreset
        case macBackgroundPreset
        case solidBackgroundPreset
        case backgroundHex
        case customGradientStartHex
        case customGradientEndHex
        case customGradientDirection
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ratio = try container.decodeIfPresent(FrameRatio.self, forKey: .ratio) ?? FrameSettings.default.ratio
        outputWidth = try container.decodeIfPresent(CGFloat.self, forKey: .outputWidth) ?? FrameSettings.default.outputWidth
        outerPadding = try container.decodeIfPresent(CGFloat.self, forKey: .outerPadding) ?? FrameSettings.default.outerPadding
        insetPadding = try container.decodeIfPresent(CGFloat.self, forKey: .insetPadding) ?? FrameSettings.default.insetPadding
        insetColorHex = try container.decodeIfPresent(String.self, forKey: .insetColorHex) ?? FrameSettings.default.insetColorHex
        usesDetectedInsetColor = try container.decodeIfPresent(Bool.self, forKey: .usesDetectedInsetColor) ?? FrameSettings.default.usesDetectedInsetColor
        cornerRadius = try container.decodeIfPresent(CGFloat.self, forKey: .cornerRadius) ?? FrameSettings.default.cornerRadius
        shadow = try container.decodeIfPresent(CGFloat.self, forKey: .shadow) ?? FrameSettings.default.shadow
        backgroundKind = try container.decodeIfPresent(BackgroundKind.self, forKey: .backgroundKind) ?? FrameSettings.default.backgroundKind
        backgroundPreset = try container.decodeIfPresent(BackgroundPreset.self, forKey: .backgroundPreset) ?? FrameSettings.default.backgroundPreset
        macBackgroundPreset = try container.decodeIfPresent(MacBackgroundPreset.self, forKey: .macBackgroundPreset) ?? FrameSettings.default.macBackgroundPreset
        solidBackgroundPreset = try container.decodeIfPresent(SolidBackgroundPreset.self, forKey: .solidBackgroundPreset) ?? FrameSettings.default.solidBackgroundPreset
        backgroundHex = try container.decodeIfPresent(String.self, forKey: .backgroundHex) ?? FrameSettings.default.backgroundHex
        customGradientStartHex = try container.decodeIfPresent(String.self, forKey: .customGradientStartHex) ?? FrameSettings.default.customGradientStartHex
        customGradientEndHex = try container.decodeIfPresent(String.self, forKey: .customGradientEndHex) ?? FrameSettings.default.customGradientEndHex
        customGradientDirection = try container.decodeIfPresent(GradientDirection.self, forKey: .customGradientDirection) ?? FrameSettings.default.customGradientDirection
    }
}

enum GradientDirection: String, CaseIterable, Codable, Identifiable {
    case right
    case left
    case down
    case up
    case diagonalDown
    case diagonalUp

    var id: String { rawValue }

    var title: String {
        switch self {
        case .right: "Right"
        case .left: "Left"
        case .down: "Down"
        case .up: "Up"
        case .diagonalDown: "Diagonal Down"
        case .diagonalUp: "Diagonal Up"
        }
    }

    var startPoint: UnitPoint {
        switch self {
        case .right: .leading
        case .left: .trailing
        case .down: .top
        case .up: .bottom
        case .diagonalDown: .topLeading
        case .diagonalUp: .bottomLeading
        }
    }

    var endPoint: UnitPoint {
        switch self {
        case .right: .trailing
        case .left: .leading
        case .down: .bottom
        case .up: .top
        case .diagonalDown: .bottomTrailing
        case .diagonalUp: .topTrailing
        }
    }
}

extension FrameSettings {
    static func decode(from string: String) -> FrameSettings {
        guard
            let data = string.data(using: .utf8),
            let settings = try? JSONDecoder().decode(FrameSettings.self, from: data)
        else {
            return .default
        }

        return settings
    }

    func encodedString() -> String {
        guard
            let data = try? JSONEncoder().encode(self),
            let string = String(data: data, encoding: .utf8)
        else {
            return ""
        }

        return string
    }
}

extension Color {
    init?(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if value.hasPrefix("#") {
            value.removeFirst()
        }

        guard value.count == 6, let rgb = UInt64(value, radix: 16) else {
            return nil
        }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255,
            green: Double((rgb & 0x00FF00) >> 8) / 255,
            blue: Double(rgb & 0x0000FF) / 255
        )
    }
}
