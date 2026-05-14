import AppKit
import SwiftUI

struct FramePreviewView: View {
    let image: NSImage?
    let settings: FrameSettings

    private var layout: FrameLayout {
        FrameLayout.calculate(settings: settings, imageSize: image?.size)
    }

    var body: some View {
        framedImagePreview
            .frame(width: layout.canvasSize.width, height: layout.canvasSize.height)
            .clipped()
    }

    private var framedImagePreview: some View {
        ZStack {
            FrameBackgroundView(settings: settings)

            RoundedRectangle(cornerRadius: settings.cornerRadius, style: .continuous)
                .fill(settings.insetColor)
                .shadow(
                    color: .black.opacity(settings.shadow > 0 ? 0.46 : 0),
                    radius: settings.shadow * 1.15,
                    x: 0,
                    y: settings.shadow * 0.45
                )
                .frame(width: layout.insetRect.width, height: layout.insetRect.height)
                .position(x: layout.insetRect.midX, y: layout.insetRect.midY)

            if let image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: max(0, settings.cornerRadius - settings.insetPadding * 0.35), style: .continuous))
                    .frame(width: layout.imageRect.width, height: layout.imageRect.height)
                    .position(x: layout.imageRect.midX, y: layout.imageRect.midY)
            }
        }
        .frame(width: layout.canvasSize.width, height: layout.canvasSize.height)
        .clipped()
    }
}

struct FrameBackgroundView: View {
    let settings: FrameSettings

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                switch settings.backgroundKind {
                case .gradient:
                    BackgroundPresetView(preset: settings.backgroundPreset)

                case .mac:
                    if let image = MacBackgroundImageCache.image(for: settings.macBackgroundPreset) {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                    } else {
                        BackgroundPresetView(preset: .dusk)
                    }

                case .solid:
                    settings.solidBackgroundPreset.color

                case .customSolid:
                    settings.backgroundColor

                case .customGradient:
                    settings.customBackgroundGradient
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }
}

struct EmptyPreviewView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(red: 0.105, green: 0.105, blue: 0.105))

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    Color.white.opacity(0.18),
                    style: StrokeStyle(lineWidth: 1, dash: [8, 8], dashPhase: 0)
                )
                .padding(24)

            VStack(spacing: 18) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 56, weight: .regular))
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: 8) {
                    Text("Drop screenshot or choose image")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.86))

                    Text("Take a screenshot with Cmd+Shift+4")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
            }
            .foregroundStyle(Color.white.opacity(0.82))
        }
    }
}
