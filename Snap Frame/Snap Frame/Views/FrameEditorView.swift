import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct FrameEditorView: View {
    private let backgroundSwatchRadius: CGFloat = 8
    private let inspectorWidth: CGFloat = 360

    @State private var state = ImageFrameDocumentState.empty
    @State private var isDropTargeted = false
    @State private var isBackgroundPopoverPresented = false
    @State private var customBackgroundMode: CustomBackgroundMode = .plainColor
    @State private var activeCustomColorPicker: CustomBackgroundColorTarget?
    @State private var isCopySuccessPresented = false

    var body: some View {
        HStack(spacing: 0) {
            previewPane
                .frame(minWidth: 620, maxWidth: .infinity)

            Divider()

            inspector
                .frame(width: inspectorWidth)
        }
        .frame(minWidth: 981, minHeight: 680)
        .overlay {
            keyboardShortcuts
                .frame(width: 0, height: 0)
                .opacity(0)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .top) {
            if isCopySuccessPresented {
                copySuccessToast
                    .padding(.top, 22)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var previewPane: some View {
        GeometryReader { proxy in
            let canvasSize = state.settings.canvasSize(imageSize: state.image?.size)
            let scale = min(
                proxy.size.width / canvasSize.width,
                proxy.size.height / canvasSize.height
            )

            ZStack {
                Color(nsColor: .windowBackgroundColor)

                if state.image == nil {
                    EmptyPreviewView()
                        .padding(20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectImage()
                        }
                } else {
                    FramePreviewView(image: state.image, settings: state.settings)
                        .frame(width: canvasSize.width, height: canvasSize.height)
                        .scaleEffect(max(0.1, scale), anchor: .center)
                        .frame(width: canvasSize.width * max(0.1, scale), height: canvasSize.height * max(0.1, scale))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isDropTargeted ? Color.accentColor : Color.clear, lineWidth: 5)
                    .padding(state.image == nil ? 36 : 0)
            }
            .overlay(alignment: .bottomTrailing) {
                if state.image != nil {
                    changeScreenshotButton
                        .padding(24)
                }
            }
            .onDrop(of: [.fileURL, .image], isTargeted: $isDropTargeted, perform: handleDrop)
        }
    }

    private var changeScreenshotButton: some View {
        Button {
            selectImage()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 42, height: 42)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .background {
            Circle()
                .fill(Color.black.opacity(0.56))
        }
        .overlay {
            Circle()
                .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.24), radius: 10, x: 0, y: 4)
        .help("Change screenshot")
        .accessibilityLabel("Change screenshot")
    }

    private var inspector: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 28) {
                backgroundPresetGrid

                VStack(alignment: .leading, spacing: 14) {
                    Picker("Ratio", selection: $state.settings.ratio) {
                        ForEach(FrameRatio.allCases) { ratio in
                            Text(ratio.title).tag(ratio)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 18) {
                    slider("Outer Padding", value: $state.settings.outerPadding, range: 24...360)
                    slider("Inset Padding", value: $state.settings.insetPadding, range: 0...140)
                }

                HStack(alignment: .top, spacing: 18) {
                    slider("Radius", value: $state.settings.cornerRadius, range: 0...80)
                    slider("Shadow", value: $state.settings.shadow, range: 0...80)
                }
            }
            .padding(32)

            Spacer(minLength: 0)

            exportButton
                .padding(.horizontal, 32)
                .padding(.top, 18)
                .padding(.bottom, 32)
        }
    }

    private var exportButton: some View {
        Button {
            exportImage()
        } label: {
            Label("Export image", systemImage: "square.and.arrow.down")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .contentShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
        .buttonStyle(.plain)
        .foregroundStyle(state.image == nil ? Color.white.opacity(0.34) : Color.white)
        .background {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(state.image == nil ? Color.white.opacity(0.12) : Color.blue)
        }
        .disabled(state.image == nil)
    }

    private var keyboardShortcuts: some View {
        Group {
            shortcutButton(key: "c") {
                copyImageToPasteboard()
            }

            shortcutButton(key: "s") {
                exportImage()
            }

            shortcutButton(key: "r") {
                resetSettings()
            }
        }
    }

    private func shortcutButton(key: KeyEquivalent, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            EmptyView()
        }
        .buttonStyle(.plain)
        .keyboardShortcut(key, modifiers: .command)
    }

    private var copySuccessToast: some View {
        Label("Image copied", systemImage: "checkmark.circle.fill")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background {
                Capsule()
                    .fill(Color.black.opacity(0.72))
            }
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
    }

    private var backgroundPresetGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

        return VStack(alignment: .leading, spacing: 10) {
            labeledValue("Background", value: "")

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(BackgroundPreset.allCases) { preset in
                    Button {
                        state.settings.backgroundKind = .gradient
                        state.settings.backgroundPreset = preset
                    } label: {
                        backgroundSwatch(
                            isSelected: state.settings.backgroundKind == .gradient && state.settings.backgroundPreset == preset
                        ) {
                            BackgroundPresetView(preset: preset)
                        }
                        .accessibilityLabel(preset.title)
                    }
                    .buttonStyle(.plain)
                }
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(MacBackgroundPreset.allCases) { preset in
                    Button {
                        state.settings.backgroundKind = .mac
                        state.settings.macBackgroundPreset = preset
                    } label: {
                        backgroundSwatch(
                            isSelected: state.settings.backgroundKind == .mac && state.settings.macBackgroundPreset == preset
                        ) {
                            if let image = MacBackgroundImageCache.image(for: preset) {
                                Image(nsImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Color.white.opacity(0.08)
                            }
                        }
                        .accessibilityLabel(preset.title)
                    }
                    .buttonStyle(.plain)
                }
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(SolidBackgroundPreset.allCases) { preset in
                    Button {
                        state.settings.backgroundKind = .solid
                        state.settings.solidBackgroundPreset = preset
                    } label: {
                        backgroundSwatch(
                            isSelected: state.settings.backgroundKind == .solid && state.settings.solidBackgroundPreset == preset
                        ) {
                            preset.color
                        }
                        .accessibilityLabel(preset.title)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    customBackgroundMode = .plainColor
                    state.settings.backgroundKind = .customSolid
                    activeCustomColorPicker = nil
                    isBackgroundPopoverPresented.toggle()
                } label: {
                    plusSwatch
                        .accessibilityLabel("Add background")
                }
                .buttonStyle(.plain)
                .popover(isPresented: $isBackgroundPopoverPresented, arrowEdge: .bottom) {
                    customBackgroundPopover
                }
            }
        }
    }

    private var customBackgroundPopover: some View {
        VStack(alignment: .leading, spacing: 18) {
            Picker("Type", selection: $customBackgroundMode) {
                ForEach(CustomBackgroundMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .onChange(of: customBackgroundMode) { _, mode in
                state.settings.backgroundKind = mode.backgroundKind
            }

            switch customBackgroundMode {
            case .plainColor:
                plainColorPicker

            case .gradient:
                gradientPicker
            }
        }
        .padding(18)
        .frame(width: 306)
    }

    private var plainColorPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("Pick a color")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                Spacer()

                colorSwatchButton(
                    color: state.settings.backgroundColor,
                    target: .plain,
                    backgroundKind: .customSolid
                )
            }

            if activeCustomColorPicker == .plain {
                InlineColorPicker(color: colorBinding(for: \.backgroundHex, activates: .customSolid))
            }
        }
    }

    private var gradientPicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text("Choose colors")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                Spacer()

                colorSwatchButton(
                    color: Color(hex: state.settings.customGradientStartHex) ?? .white,
                    target: .gradientStart,
                    backgroundKind: .customGradient
                )

                colorSwatchButton(
                    color: Color(hex: state.settings.customGradientEndHex) ?? .white,
                    target: .gradientEnd,
                    backgroundKind: .customGradient
                )
            }

            if activeCustomColorPicker == .gradientStart {
                InlineColorPicker(color: colorBinding(for: \.customGradientStartHex, activates: .customGradient))
            } else if activeCustomColorPicker == .gradientEnd {
                InlineColorPicker(color: colorBinding(for: \.customGradientEndHex, activates: .customGradient))
            }

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(state.settings.customBackgroundGradient)
                .frame(height: 46)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                }
                .onTapGesture {
                    state.settings.backgroundKind = .customGradient
                }

            Picker("Direction", selection: directionBinding) {
                ForEach(GradientDirection.allCases) { direction in
                    Text(direction.title).tag(direction)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var directionBinding: Binding<GradientDirection> {
        Binding(
            get: { state.settings.customGradientDirection },
            set: { direction in
                state.settings.backgroundKind = .customGradient
                state.settings.customGradientDirection = direction
            }
        )
    }

    private func colorSwatchButton(
        color: Color,
        target: CustomBackgroundColorTarget,
        backgroundKind: BackgroundKind
    ) -> some View {
        Button {
            state.settings.backgroundKind = backgroundKind
            activeCustomColorPicker = activeCustomColorPicker == target ? nil : target
        } label: {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(color)
                .frame(width: 42, height: 30)
                .overlay {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .strokeBorder(
                            activeCustomColorPicker == target ? Color.accentColor : Color.white.opacity(0.22),
                            lineWidth: activeCustomColorPicker == target ? 2 : 1
                        )
                }
                .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func colorBinding(
        for keyPath: WritableKeyPath<FrameSettings, String>,
        activates backgroundKind: BackgroundKind
    ) -> Binding<Color> {
        Binding(
            get: {
                Color(hex: state.settings[keyPath: keyPath]) ?? .white
            },
            set: { color in
                state.settings.backgroundKind = backgroundKind
                state.settings[keyPath: keyPath] = color.hexString
            }
        )
    }

    private func backgroundSwatch<Content: View>(
        isSelected: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        RoundedRectangle(cornerRadius: backgroundSwatchRadius, style: .continuous)
            .fill(Color.clear)
            .frame(height: 44)
            .background {
                content()
                    .clipShape(RoundedRectangle(cornerRadius: backgroundSwatchRadius, style: .continuous))
            }
            .overlay {
                RoundedRectangle(cornerRadius: backgroundSwatchRadius, style: .continuous)
                    .strokeBorder(isSelected ? Color.white : Color.white.opacity(0.16), lineWidth: isSelected ? 3 : 1)
            }
            .clipped()
    }

    private var plusSwatch: some View {
        RoundedRectangle(cornerRadius: backgroundSwatchRadius, style: .continuous)
            .fill(Color.white.opacity(0.08))
            .frame(height: 44)
            .overlay {
                RoundedRectangle(cornerRadius: backgroundSwatchRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
            }
            .overlay {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.72))
            }
    }

    private func slider(_ title: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            labeledValue(title, value: "\(Int(value.wrappedValue))")
            Slider(value: value, in: range)
        }
    }

    private func labeledValue(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            if !value.isEmpty {
                Text(value)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
                    guard
                        let data,
                        let url = URL(dataRepresentation: data, relativeTo: nil)
                    else {
                        return
                    }

                    loadImage(from: url)
                }
                return true
            }

            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                    guard
                        let data,
                        let image = NSImage(data: data)
                    else {
                        return
                    }

                    Task { @MainActor in
                        setImage(image)
                    }
                }
                return true
            }
        }

        return false
    }

    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        loadImage(from: url)
    }

    private func loadImage(from url: URL) {
        guard let image = NSImage(contentsOf: url) else {
            NSSound.beep()
            return
        }

        Task { @MainActor in
            setImage(image)
        }
    }

    @MainActor
    private func exportImage() {
        guard let image = state.image else {
            NSSound.beep()
            return
        }

        ExportRenderer.savePNG(image: image, settings: state.settings)
    }

    @MainActor
    private func setImage(_ image: NSImage) {
        state.setImage(image)
        applyDetectedInsetColor(from: image)
    }

    @MainActor
    private func copyImageToPasteboard() {
        guard
            let image = state.image,
            let data = ExportRenderer.pngData(image: image, settings: state.settings)
        else {
            NSSound.beep()
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(data, forType: .png)
        showCopySuccess()
    }

    @MainActor
    private func showCopySuccess() {
        withAnimation(.snappy(duration: 0.18)) {
            isCopySuccessPresented = true
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation(.snappy(duration: 0.18)) {
                isCopySuccessPresented = false
            }
        }
    }

    @MainActor
    private func resetSettings() {
        state.settings = .default
        activeCustomColorPicker = nil
        customBackgroundMode = .plainColor

        if let image = state.image {
            applyDetectedInsetColor(from: image)
        }
    }

    @MainActor
    private func applyDetectedInsetColor(from image: NSImage) {
        guard
            state.settings.usesDetectedInsetColor,
            let colorHex = ImageColorSampler.detectedBackgroundHex(from: image)
        else {
            return
        }

        state.settings.insetColorHex = colorHex
    }
}

private enum CustomBackgroundMode: String, CaseIterable, Identifiable {
    case plainColor
    case gradient

    var id: String { rawValue }

    var title: String {
        switch self {
        case .plainColor: "Plain Color"
        case .gradient: "Gradient"
        }
    }

    var backgroundKind: BackgroundKind {
        switch self {
        case .plainColor: .customSolid
        case .gradient: .customGradient
        }
    }
}

private enum CustomBackgroundColorTarget {
    case plain
    case gradientStart
    case gradientEnd
}

private struct InlineColorPicker: View {
    @Binding var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ColorWheel(color: $color)
                .frame(width: 168, height: 168)
                .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                Image(systemName: "sun.max")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 16)

                Slider(value: brightnessBinding, in: 0...1)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        }
    }

    private var brightnessBinding: Binding<Double> {
        Binding(
            get: {
                color.hsbComponents.brightness
            },
            set: { value in
                var components = color.hsbComponents
                components.brightness = value
                color = components.color
            }
        )
    }
}

private struct ColorWheel: View {
    @Binding var color: Color

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let radius = size / 2
            let components = color.hsbComponents
            let marker = markerPosition(center: center, radius: radius, hue: components.hue, saturation: components.saturation)

            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [
                                .red,
                                .yellow,
                                .green,
                                .cyan,
                                .blue,
                                .purple,
                                .pink,
                                .red,
                            ],
                            center: .center
                        )
                    )
                    .overlay {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.white, .white.opacity(0)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: radius
                                )
                            )
                    }
                    .overlay {
                        Circle()
                            .fill(Color.black.opacity(1 - components.brightness))
                    }
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    }

                Circle()
                    .strokeBorder(Color.white, lineWidth: 2)
                    .background {
                        Circle()
                            .strokeBorder(Color.black.opacity(0.42), lineWidth: 4)
                    }
                    .frame(width: 16, height: 16)
                    .position(marker)
            }
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateColor(at: value.location, center: center, radius: radius)
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func markerPosition(center: CGPoint, radius: CGFloat, hue: Double, saturation: Double) -> CGPoint {
        let angle = hue * .pi * 2
        let distance = radius * saturation

        return CGPoint(
            x: center.x + cos(angle) * distance,
            y: center.y + sin(angle) * distance
        )
    }

    private func updateColor(at location: CGPoint, center: CGPoint, radius: CGFloat) {
        let dx = location.x - center.x
        let dy = location.y - center.y
        let distance = min(radius, sqrt(dx * dx + dy * dy))
        let saturation = max(0, min(1, distance / radius))
        let rawHue = atan2(dy, dx) / (.pi * 2)
        let hue = rawHue < 0 ? rawHue + 1 : rawHue
        let brightness = color.hsbComponents.brightness

        color = Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}

private struct RGBComponents {
    var red: Double
    var green: Double
    var blue: Double

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }
}

private struct HSBComponents {
    var hue: Double
    var saturation: Double
    var brightness: Double

    var color: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}

private extension Color {
    var rgbComponents: RGBComponents {
        let nsColor = NSColor(self)
        guard
            let rgbColor = nsColor.usingColorSpace(.sRGB)
        else {
            return RGBComponents(red: 1, green: 1, blue: 1)
        }

        return RGBComponents(
            red: rgbColor.redComponent,
            green: rgbColor.greenComponent,
            blue: rgbColor.blueComponent
        )
    }

    var hsbComponents: HSBComponents {
        let nsColor = NSColor(self)
        guard
            let rgbColor = nsColor.usingColorSpace(.sRGB)
        else {
            return HSBComponents(hue: 0, saturation: 0, brightness: 1)
        }

        return HSBComponents(
            hue: rgbColor.hueComponent.isFinite ? rgbColor.hueComponent : 0,
            saturation: rgbColor.saturationComponent.isFinite ? rgbColor.saturationComponent : 0,
            brightness: rgbColor.brightnessComponent.isFinite ? rgbColor.brightnessComponent : 1
        )
    }

    var hexString: String {
        let components = rgbComponents
        let red = Int(round(components.red * 255))
        let green = Int(round(components.green * 255))
        let blue = Int(round(components.blue * 255))

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
