# Snap Frame

macOS app for turning screenshots into polished framed images. Drop in a screenshot, choose a background, tune the spacing, radius, and shadow, then export or copy a ready-to-share PNG.

![Snap Frame](screenshot.png)

## Features

- Drag and drop a screenshot or choose one with the file picker
- Supports image files and image data from the pasteboard/drop system
- Includes gradient, solid color, and macOS desktop background presets
- Supports custom solid color and custom two-color gradient backgrounds
- Provides Auto, 3:2, 4:3, 16:9, and 1:1 output ratios
- Automatically detects the screenshot edge color for the inset frame
- Lets you adjust outer padding, inset padding, corner radius, and shadow
- Exports the final composition as a PNG image
- Copies the rendered PNG to the pasteboard with `Command-C`
- Supports `Command-S` for export and `Command-R` to reset settings

## Requirements

- macOS 15.5+
- Xcode 16+
- Swift 5

The project has no third-party package dependencies. Clone it and open it in Xcode.

## Download

Download the latest release from:

[https://github.com/zenkarsha/snap-frame/releases](https://github.com/zenkarsha/snap-frame/releases)

After installing the app, macOS may block it on first launch. If that happens, go to `System Settings > Privacy & Security` and click `Open Anyway`.

## Run

Using Xcode:

1. Open `Snap Frame/Snap Frame.xcodeproj`
2. Select the `Snap Frame` scheme
3. Run the app

Using the command line:

```bash
xcodebuild \
  -project "Snap Frame/Snap Frame.xcodeproj" \
  -scheme "Snap Frame" \
  -destination "platform=macOS" \
  build
```

## Test

```bash
xcodebuild \
  test \
  -project "Snap Frame/Snap Frame.xcodeproj" \
  -scheme "Snap Frame" \
  -destination "platform=macOS" \
  -derivedDataPath ".deriveddata/test"
```

## Local Install

The repo includes an install script that will:

- Build the app with the `Release` configuration
- Stop the currently running `Snap Frame` process if needed
- Copy the `.app` bundle to `/Applications`

Command:

```bash
./scripts/install_local.sh
```

## Project Structure

```text
.
├── README.md
├── Snap Frame/
│   ├── Snap Frame.xcodeproj
│   ├── Snap Frame/
│   │   ├── Snap_FrameApp.swift
│   │   ├── ContentView.swift
│   │   ├── Services/
│   │   │   ├── ExportRenderer.swift
│   │   │   ├── ImageColorSampler.swift
│   │   │   └── MacBackgroundImageCache.swift
│   │   ├── Views/
│   │   │   ├── BackgroundPresetView.swift
│   │   │   ├── FrameEditorView.swift
│   │   │   └── FramePreviewView.swift
│   │   ├── Models/
│   │   │   ├── FrameLayout.swift
│   │   │   ├── FrameRatio.swift
│   │   │   ├── FrameSettings.swift
│   │   │   └── ImageFrameDocumentState.swift
│   │   ├── Backgrounds/
│   │   ├── Snap_Frame.entitlements
│   │   └── Assets.xcassets/
│   ├── Snap FrameTests/
│   └── Snap FrameUITests/
├── Snap Frame-icon/
└── scripts/
```

## License

MIT License
