# Architecture

## Layout

```
Kropic/
├── project.yml                  XcodeGen spec
├── Configs/
│   ├── Base.xcconfig            shared build settings
│   ├── Local.example.xcconfig   template, committed
│   └── Local.xcconfig           DEVELOPMENT_TEAM etc, gitignored
├── App/                         macOS app target
│   ├── KropicApp.swift           entry point, MenuBarExtra
│   ├── AppState.swift           top-level @Observable state and coordination
│   ├── MenuBar/
│   ├── Hotkey/
│   ├── Permissions/             Screen Recording check, onboarding window
│   ├── Capture/                 selection overlay windows and views, CaptureService
│   ├── ResultPanel/             floating NSPanel, SwiftUI result view, view model
│   ├── Translation/             AppleTranslationProvider (needs SwiftUI, see below)
│   └── Settings/
├── Packages/KropicCore/          local Swift package, no AppKit or UIKit imports
│   ├── Sources/KropicCore/
│   │   ├── OCR/                 TextRecognizer
│   │   ├── Language/            LanguageDetector
│   │   └── Translation/         Translating protocol, shared types
│   └── Tests/KropicCoreTests/    includes fixture images with known text
└── docs/
```

KropicCore must compile for both macOS and iOS so a future iPhone app can reuse it. It only imports Foundation, CoreGraphics, Vision and NaturalLanguage.

## Components

**AppState** owns the flow. Idle → selecting → capturing → showing result. It is `@MainActor` and talks to the services below.

**HotkeyService** wraps KeyboardShortcuts and calls AppState when the shortcut fires.

**PermissionService** uses `CGPreflightScreenCaptureAccess()` and `CGRequestScreenCaptureAccess()`. The System Settings deep link is `x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture`.

**AppearanceService** stores the user's choice (system, light, dark) in UserDefaults and sets `NSApp.appearance` to nil, `.aqua` or `.darkAqua`. SwiftUI views and AppKit windows follow automatically. All colors come from the asset catalog with Any and Dark variants, so views never branch on the theme themselves.

**SelectionOverlay**
- One borderless, transparent `NSPanel` per display, covering the full frame, at a window level above normal windows and the menu bar
- Hosts a SwiftUI view that draws the dim layer, the selection rectangle, resize handles and the checkmark button
- Must become key so it receives Esc and Enter
- Returns the selected rectangle in global screen coordinates plus the display it belongs to

**CaptureService**
- Uses ScreenCaptureKit (`SCShareableContent`, `SCContentFilter`, `SCScreenshotManager`)
- Exclude Kropic's own windows from the capture so the overlay never appears in the image
- Coordinate pitfalls. AppKit uses a bottom-left origin and points. ScreenCaptureKit and CGImage use a top-left origin and pixels. Convert per display using its frame and backing scale factor. Write unit-testable helpers for this conversion
- Returns a `CGImage` held in memory only

**TextRecognizer** (KropicCore)
- Prefer the Swift Vision API on macOS 15 (`RecognizeTextRequest`) over the older `VNRecognizeTextRequest` if it covers our needs
- Accurate recognition level, language correction on, automatic language detection on
- Sort observations top to bottom then left to right and rebuild line breaks so paragraphs survive
- Returns text plus per-line confidence

**LanguageDetector** (KropicCore) uses `NLLanguageRecognizer` and returns the dominant language. Short or mixed text can be detected wrongly, so the UI always allows an override.

**Translation**
- KropicCore defines a `Translating` protocol and the shared types (language, request, result). Cloud providers can implement it later
- `AppleTranslationProvider` lives in the app target. On macOS 15 a `TranslationSession` is only obtained through the SwiftUI `.translationTask` modifier, so the provider is driven by a view in the result panel. If the SDK on this machine allows creating a session directly, use that behind the same protocol and record it in DECISIONS.md
- Check `LanguageAvailability` before translating to tell apart installed, downloadable and unsupported pairs

**ResultPanel** is a floating `NSPanel` positioned next to the selection and clamped to the visible frame of that display. Content is SwiftUI. The view model holds image, extracted text, detected and chosen languages, translation and loading or error state.

## Concurrency

- Everything UI related is `@MainActor`
- OCR and capture run off the main actor and return `Sendable` values
- Cancel in-flight OCR or translation when a new capture starts or the text is edited

## Testing

- KropicCore has unit tests. OCR runs against fixture images with known Turkish and English text. Language detection and coordinate conversion have plain unit tests
- UI, permissions and overlay behavior are tested by hand using the checklist at the end of each phase