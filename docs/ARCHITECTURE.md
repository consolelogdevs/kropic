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
│   ├── AppDelegate.swift         owns AppState, starts it after launch
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
│   │   ├── Geometry/            coordinate conversion, selection math, placement
│   │   ├── OCR/                 TextRecognizer
│   │   ├── Language/            LanguageDetector
│   │   └── Translation/         Translating protocol, shared types
│   └── Tests/KropicCoreTests/    includes fixture images with known text
└── docs/
```

KropicCore must compile for both macOS and iOS so a future iPhone app can reuse it. It only imports Foundation, CoreGraphics, Vision and NaturalLanguage.

## Components

**AppState** owns the flow. Idle → selecting → capturing → showing result. It is `@MainActor` and talks to the services below.

**HotkeyService** wraps KeyboardShortcuts and calls AppState when the shortcut fires. It listens with the `KeyboardShortcuts.events(.keyUp, for:)` async stream, because `onKeyUp` is slated for deprecation.

**PermissionService** uses `CGPreflightScreenCaptureAccess()` and `CGRequestScreenCaptureAccess()`. The System Settings deep link is `x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture` (older form, to be confirmed on macOS 15+; the newer form is `com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture`). The onboarding window is AppKit-hosted (`OnboardingWindowController`) so it can be opened from the hotkey path.

**SelectionOverlay**
- One borderless, transparent `NSPanel` per display, covering the full frame, at `.screenSaver` level (above the menu bar and Dock). Every display dims; the selection belongs to the display where the drag starts
- A shared `SelectionModel` (`@Observable`) holds the selection for all displays
- Hosts a SwiftUI view that draws the dim layer, the selection rectangle, resize handles and the checkmark button
- Kropic activates itself while the overlay is open (`FocusRestorer`) so the panels receive mouse and key events, and hands focus back to the previous app on cancel or when the result panel closes. Hosting views accept the first click so a drag on a non-key display works. Keys are intercepted in the panel's `sendEvent`
- `SelectionOverlayController.select()` returns the selected rectangle in display-local points plus the display ID and frames, or `nil` on cancel

**CaptureService**
- Uses ScreenCaptureKit: `SCShareableContent` → `SCContentFilter(display:excludingApplications:exceptingWindows:)` → `SCScreenshotManager.captureImage(contentFilter:configuration:)` (macOS 14+). Not `captureImage(in:)`, which needs macOS 15.2 and cannot exclude windows
- Exclude Kropic's own windows from the capture so the overlay never appears in the image
- Coordinate pitfalls. AppKit uses a bottom-left origin in global points. `SCStreamConfiguration.sourceRect` is in display-local **points** with a top-left origin; only the output `width`/`height` are pixels (points × `SCContentFilter.pointPixelScale`). SwiftUI views covering a display already use display-local top-left points, so the selection needs no conversion for capture. Helpers live in `KropicCore/Geometry/ScreenGeometry` with unit tests
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

**ResultPanel** is a floating `NSPanel` positioned next to the selection (right, left, below, above) and clamped to the visible frame of that display (`Placement.panelFrame`). Content is SwiftUI. The view model holds image, extracted text, detected and chosen languages, translation and loading or error state.

## Concurrency

- Everything UI related is `@MainActor`
- OCR and capture run off the main actor and return `Sendable` values
- Cancel in-flight OCR or translation when a new capture starts or the text is edited

## Testing

- KropicCore has unit tests. OCR runs against fixture images with known Turkish and English text. Language detection and coordinate conversion have plain unit tests
- UI, permissions and overlay behavior are tested by hand using the checklist at the end of each phase
