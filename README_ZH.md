**[English](README.md)** | 中文

# Snap Frame

Snap Frame 是一款 macOS App，可將截圖轉成帶有精緻外框的圖片。放入截圖後，選擇背景、調整間距、圓角與陰影，就能匯出或複製一張可直接分享的 PNG。

![Snap Frame](screenshot.png)

## 功能

- 可拖放截圖，或透過檔案選擇器選取圖片
- 支援圖片檔案，以及來自剪貼簿或拖放系統的圖片資料
- 內建漸層、純色與 macOS 桌面背景預設
- 支援自訂純色背景與雙色漸層背景
- 提供 Auto、3:2、4:3、16:9 與 1:1 輸出比例
- 自動偵測截圖邊緣顏色，作為內框顏色
- 可調整外側留白、內框留白、圓角與陰影
- 使用 `Cmd + C` 將渲染後的 PNG 複製到剪貼簿
- 支援 `Cmd + S` 匯出，以及 `Cmd + R` 重設設定

## 系統需求

- macOS 15.5+
- Xcode 16+
- Swift 5

此專案沒有第三方套件相依。Clone 專案後，用 Xcode 開啟即可。

## 下載

從以下位置下載最新版本：

[https://github.com/zenkarsha/snap-frame/releases](https://github.com/zenkarsha/snap-frame/releases)

安裝 App 後，macOS 可能會在第一次啟動時阻擋它。如果發生這種情況，請前往 `系統設定 > 隱私權與安全性`，然後點擊 `強制打開`。

## 執行

使用 Xcode：

1. 開啟 `Snap Frame/Snap Frame.xcodeproj`
2. 選擇 `Snap Frame` scheme
3. 執行 App

使用命令列：

```bash
xcodebuild \
  -project "Snap Frame/Snap Frame.xcodeproj" \
  -scheme "Snap Frame" \
  -destination "platform=macOS" \
  build
```

## 測試

```bash
xcodebuild \
  test \
  -project "Snap Frame/Snap Frame.xcodeproj" \
  -scheme "Snap Frame" \
  -destination "platform=macOS" \
  -derivedDataPath ".deriveddata/test"
```

## 本機安裝

此 repo 包含一支安裝腳本，會執行以下動作：

- 使用 `Release` configuration 建置 App
- 視需要停止目前正在執行的 `Snap Frame` process
- 將 `.app` bundle 複製到 `/Applications`

指令：

```bash
./scripts/install_local.sh
```

## 專案結構

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

## 授權

MIT License
