import SwiftUI

struct BackgroundPresetView: View {
    let preset: BackgroundPreset

    var body: some View {
        GeometryReader { proxy in
            let palette = preset.palette
            let width = proxy.size.width
            let height = proxy.size.height
            let blurRadius = min(width, height) * 0.18

            ZStack {
                LinearGradient(
                    colors: palette.baseColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                ForEach(palette.spots) { spot in
                    softSpot(
                        color: spot.color,
                        opacity: spot.opacity,
                        width: width * spot.width,
                        height: height * spot.height,
                        x: width * spot.x,
                        y: height * spot.y,
                        blurRadius: blurRadius
                    )
                }
            }
        }
    }

    private func softSpot(
        color: Color,
        opacity: Double,
        width: CGFloat,
        height: CGFloat,
        x: CGFloat,
        y: CGFloat,
        blurRadius: CGFloat
    ) -> some View {
        Ellipse()
            .fill(color.opacity(opacity))
            .frame(width: width, height: height)
            .position(x: x, y: y)
            .blur(radius: blurRadius)
    }
}

private struct BackgroundPalette {
    let baseColors: [Color]
    let spots: [BackgroundSpot]
}

private struct BackgroundSpot: Identifiable {
    let id: String
    let color: Color
    let opacity: Double
    let width: CGFloat
    let height: CGFloat
    let x: CGFloat
    let y: CGFloat
}

private extension BackgroundPreset {
    var palette: BackgroundPalette {
        switch self {
        case .rose:
            BackgroundPalette(
                baseColors: colors("#FF8D84", "#FFC076", "#96C7D5", "#D161B0"),
                spots: [
                    spot("#FFD071", 0.64, 0.72, 0.72, 0.34, 0.18),
                    spot("#8CCAD8", 0.74, 0.68, 0.74, 0.88, 0.12),
                    spot("#D75BB1", 0.70, 0.86, 0.76, 0.78, 0.82),
                    spot("#FF7668", 0.54, 0.66, 0.82, 0.12, 0.76)
                ]
            )

        case .cool:
            BackgroundPalette(
                baseColors: colors("#D8E6E2", "#B5CEC8", "#8BA9BE", "#D3BBC7"),
                spots: [
                    spot("#F1E4C8", 0.58, 0.72, 0.70, 0.18, 0.16),
                    spot("#9EC6C2", 0.72, 0.76, 0.78, 0.86, 0.22),
                    spot("#8EA4C7", 0.62, 0.82, 0.74, 0.76, 0.82),
                    spot("#D8B4C1", 0.48, 0.68, 0.76, 0.12, 0.82)
                ]
            )

        case .beach:
            BackgroundPalette(
                baseColors: colors("#EAD6B8", "#B9C8A3", "#83B7A9", "#D19A86"),
                spots: [
                    spot("#F2C88C", 0.56, 0.76, 0.68, 0.30, 0.14),
                    spot("#AFCB9A", 0.66, 0.72, 0.74, 0.84, 0.20),
                    spot("#6FAEA2", 0.62, 0.84, 0.78, 0.78, 0.76),
                    spot("#D88E7A", 0.52, 0.72, 0.82, 0.10, 0.82)
                ]
            )

        case .violet:
            BackgroundPalette(
                baseColors: colors("#CAB8D9", "#E1C3BD", "#8FA3AE", "#485D75"),
                spots: [
                    spot("#E8D0C2", 0.58, 0.76, 0.68, 0.20, 0.16),
                    spot("#A99CCF", 0.70, 0.76, 0.78, 0.82, 0.22),
                    spot("#637E95", 0.62, 0.86, 0.80, 0.82, 0.78),
                    spot("#D7B2C0", 0.46, 0.70, 0.82, 0.10, 0.80)
                ]
            )

        case .love:
            BackgroundPalette(
                baseColors: colors("#E7A6A1", "#D27B86", "#A06E8E", "#F0D2BE"),
                spots: [
                    spot("#F1C4A4", 0.60, 0.74, 0.70, 0.22, 0.16),
                    spot("#D96F7B", 0.66, 0.76, 0.78, 0.84, 0.22),
                    spot("#9E6B91", 0.62, 0.84, 0.80, 0.78, 0.82),
                    spot("#E6A7A0", 0.50, 0.70, 0.82, 0.10, 0.78)
                ]
            )

        case .flower:
            BackgroundPalette(
                baseColors: colors("#E6D7F2", "#B9A0D8", "#7E71B8", "#D8AECF"),
                spots: [
                    spot("#F0D7EC", 0.58, 0.76, 0.68, 0.22, 0.16),
                    spot("#A88BD5", 0.72, 0.76, 0.78, 0.86, 0.22),
                    spot("#6D66B3", 0.62, 0.86, 0.78, 0.78, 0.80),
                    spot("#D6A6C8", 0.50, 0.72, 0.82, 0.10, 0.82)
                ]
            )

        case .sky:
            BackgroundPalette(
                baseColors: colors("#C5DDE3", "#E2D4BC", "#C4B6D5", "#86A8B6"),
                spots: [
                    spot("#F0D6B5", 0.52, 0.76, 0.68, 0.18, 0.16),
                    spot("#9DC4CE", 0.72, 0.76, 0.78, 0.86, 0.18),
                    spot("#B9A9D0", 0.62, 0.84, 0.78, 0.80, 0.80),
                    spot("#D8E5DD", 0.46, 0.72, 0.82, 0.10, 0.82)
                ]
            )

        case .dusk:
            BackgroundPalette(
                baseColors: colors("#2C353A", "#574B5C", "#9B746B", "#D0A86F"),
                spots: [
                    spot("#D6B07A", 0.50, 0.72, 0.66, 0.22, 0.18),
                    spot("#6F5B73", 0.66, 0.76, 0.78, 0.86, 0.18),
                    spot("#A8796E", 0.58, 0.84, 0.78, 0.78, 0.80),
                    spot("#283C43", 0.54, 0.72, 0.82, 0.10, 0.82)
                ]
            )

        case .lime:
            BackgroundPalette(
                baseColors: colors("#E6DFA9", "#B7C77C", "#82A08B", "#D2C3A8"),
                spots: [
                    spot("#F0E6A6", 0.62, 0.76, 0.68, 0.22, 0.16),
                    spot("#B4CC72", 0.68, 0.76, 0.78, 0.86, 0.22),
                    spot("#7FA388", 0.60, 0.86, 0.78, 0.78, 0.80),
                    spot("#D7BDA2", 0.48, 0.72, 0.82, 0.10, 0.82)
                ]
            )

        case .aurora:
            BackgroundPalette(
                baseColors: colors("#D9E3C6", "#A7BFA4", "#7DA7A8", "#C9A6B8"),
                spots: [
                    spot("#E7D8B7", 0.58, 0.76, 0.68, 0.20, 0.16),
                    spot("#93BDA4", 0.70, 0.76, 0.78, 0.86, 0.20),
                    spot("#729FAE", 0.62, 0.86, 0.78, 0.78, 0.80),
                    spot("#CFA4BB", 0.50, 0.72, 0.82, 0.10, 0.82)
                ]
            )
        }
    }

    private func colors(_ hexValues: String...) -> [Color] {
        hexValues.compactMap(Color.init(hex:))
    }

    private func spot(
        _ hex: String,
        _ opacity: Double,
        _ width: CGFloat,
        _ height: CGFloat,
        _ x: CGFloat,
        _ y: CGFloat
    ) -> BackgroundSpot {
        BackgroundSpot(
            id: "\(hex)-\(x)-\(y)",
            color: Color(hex: hex) ?? .clear,
            opacity: opacity,
            width: width,
            height: height,
            x: x,
            y: y
        )
    }
}
