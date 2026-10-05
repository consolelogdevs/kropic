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
│   ├── MenuBar/                 MenuBarContent, RecentTranslationsMenu (last 5, Show All…)
│   ├── Hotkey/
│   ├── Permissions/             Screen Recording check, onboarding view
│   ├── Windows/                 HostingWindowController (onboarding, settings, history)
│   ├── History/                 history window and view model
│   ├── Resources/               Kropic.icon (Icon Composer app icon), Assets.xcassets (MenuBarIcon, AccentColor, color tokens), Localizable.xcstrings
│   ├── Design/                  Theme (semantic tokens), Typography, Metrics; Components/ (shared views and button styles); Previews/ (debug render harness)
│   ├── Annotation/              AnnotationTool, colors, AnnotationShapeView (on-screen preview of marks)
│   ├── Export/                  ImageExporter (copy, save), SharePresenter
│   ├── Capture/                 selection overlay windows and views, CaptureService
│   ├── ResultPanel/             floating NSPanel, SwiftUI result view, view model
│   ├── Translation/             AppleTranslationProvider (needs SwiftUI, see below)
│   └── Settings/                AppSettings (UserDefaults), SettingsView, LaunchAtLogin
├── Packages/KropicCore/          local Swift package, no AppKit or UIKit imports
│   ├── Sources/KropicCore/
│   │   ├── Geometry/            coordinate conversion, selection math, placement
│   │   ├── OCR/                 TextRecognizer
│   │   ├── History/             HistoryEntry, HistoryStore (JSON file, newest 20)
│   │   ├── Annotation/          Annotation, AnnotationDocument (undo/redo), AnnotationRenderer
│   │   ├── Language/            LanguageDetector
│   │   └── Translation/         Translating protocol, shared types
│   └── Tests/KropicCoreTests/    OCR tests render known text into in-memory images
└── docs/
```

User facing text: SwiftUI literals are localizable automatically; every other user facing `String` (errors, window titles, composed messages) uses `String(localized:)`, with `bundle: .module` inside KropicCore, which has its own catalog in `Sources/KropicCore/Resources`. `Scripts/sync-strings.sh` merges the compiler's extracted strings into both catalogs.

KropicCore must compile for both macOS and iOS so a future iPhone app can reuse it. It only imports Foundation, CoreGraphics, CoreText (annotation text), Vision and NaturalLanguage.

## Components

**AppState** owns the flow. Idle → selecting → capturing → showing result. It is `@MainActor` and talks to the services below.

**HotkeyService** wraps KeyboardShortcuts and calls AppState when the shortcut fires. It listens with the `KeyboardShortcuts.events(.keyUp, for:)` async stream, because `onKeyUp` is slated for deprecation.

**PermissionService** uses `CGPreflightScreenCaptureAccess()` and `CGRequestScreenCaptureAccess()`. The System Settings deep link is `x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture` (older form, to be confirmed on macOS 15+; the newer form is `com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture`). The onboarding window is AppKit-hosted (`HostingWindowController`) so it can be opened from the hotkey path.

**AppearanceService** applies the user's choice (system, light, dark) by setting `NSApp.appearance` to nil, `.aqua` or `.darkAqua`. The choice itself is stored by `AppSettings` (the single owner of UserDefaults keys), which calls the service whenever it changes and once at launch. SwiftUI views and AppKit windows follow automatically. All colors come from the asset catalog with Any and Dark variants, so views never branch on the theme themselves.

**SelectionOverlay**
- One borderless, transparent `NSPanel` per display, covering the full frame, at `.screenSaver` level (above the menu bar and Dock). Every display dims; the selection belongs to the display where the drag starts
- A shared `SelectionModel` (`@Observable`) holds the selection for all displays
- Hosts a SwiftUI view that draws the dim layer, the selection outline, resize handles, the size label, the cancel and confirm bar below the selection, and a hint pill below the menu bar on the display under the cursor. The panels always use the light appearance, so the overlay looks the same in both themes
- Kropic activates itself while the overlay is open (`FocusRestorer`) so the panels receive mouse and key events, and hands focus back to the previous app on cancel or when the result panel closes. Hosting views accept the first click so a drag on a non-key display works. Keys are intercepted in the panel's `sendEvent`
- `SelectionOverlayController.select()` returns the selected rectangle in display-local points plus the display ID and frames, or `nil` on cancel

**CaptureService**
- Uses ScreenCaptureKit: `SCShareableContent` → `SCContentFilter(display:excludingApplications:exceptingWindows:)` → `SCScreenshotManager.captureImage(contentFilter:configuration:)` (macOS 14+). Not `captureImage(in:)`, which needs macOS 15.2 and cannot exclude windows
- Exclude Kropic's own windows from the capture so the overlay never appears in the image
- Coordinate pitfalls. AppKit uses a bottom-left origin in global points. `SCStreamConfiguration.sourceRect` is in display-local **points** with a top-left origin; only the output `width`/`height` are pixels (points × `SCContentFilter.pointPixelScale`). SwiftUI views covering a display already use display-local top-left points, so the selection needs no conversion for capture. Helpers live in `KropicCore/Geometry/ScreenGeometry` with unit tests
- Returns a `CGImage` held in memory only

**TextRecognizer** (KropicCore)
- Uses the Swift Vision API (`RecognizeTextRequest`, macOS 15). Accurate recognition level, language correction on, automatic language detection on. No explicit language list: Turkish diacritics survive with automatic detection (see tests)
- `TextLayout` rebuilds the text: pieces at the same height form a row (joined left to right), rows go top to bottom, a gap larger than 0.8 × the median line height becomes a blank line. Vision's own paragraph info (`shouldWrapToNextLine`, `RecognizeDocumentsRequest`) is macOS 26 only
- Known limitation: side-by-side columns are interleaved row by row
- Returns `RecognizedText`: the rebuilt text plus each line with its confidence and normalized position

**LanguageDetector** (KropicCore) uses `NLLanguageRecognizer` and returns the dominant language, or `nil` for text with fewer than 3 letters or confidence below 0.5. Short or mixed text can be detected wrongly, so the UI always allows an override. When our detection gives `nil`, the source is left empty and Apple's framework identifies the language itself.

**Translation**
- KropicCore defines a `@MainActor` `Translating` protocol and the shared types (request, result, availability, `TranslationFailure`). Cloud providers can implement it later
- `AppleTranslationProvider` lives in the app target. On macOS 15 a `TranslationSession` is only obtained through the SwiftUI `.translationTask` modifier. `translate()` queues the request and changes the session configuration (or calls `invalidate()` for the same pair); `TranslationHost`, attached to the result view, runs the task, translates and hands the outcome back, which resumes the caller. `TranslationSession(installedSource:target:)` exists but needs macOS 26 and installed packs, so it is not used (D-023)
- `TranslationSession` and `LanguageAvailability` are not `Sendable`. They are only used inside `nonisolated` code and never cross to the main actor
- Check `LanguageAvailability` before translating to tell apart installed, downloadable and unsupported pairs. Translating a downloadable pair makes the system show its download prompt on the result panel. Declining it has no dedicated error, so a failure on a still-downloadable pair is reported as a missing language pack
- `TranslationViewModel` owns the pickers and states. Edits re-translate after a 0.6 s debounce; picker changes translate immediately. `LanguageCatalog` maps detected or system languages to Apple's list (e.g. `en-TR` → `en`) and remembers the last target in `UserDefaults`

**Settings and History** are AppKit-hosted windows (`HostingWindowController`), not SwiftUI scenes, so they come to the front in a menu bar only app. `AppSettings` is the single owner of UserDefaults keys. `LaunchAtLogin` wraps `SMAppService.mainApp`; its state lives in the system. `HistoryStore` (KropicCore actor) keeps the newest 20 entries in `History.json` in Application Support (the sandbox container). `AppState` saves the open result when its panel closes or is replaced.

**Capture toolbar and annotation** live in the overlay. `OverlayAnnotations` holds the tool (`nil` is Move), color and an `AnnotationDocument` in display-local points. `SelectionOverlayController` routes mouse input: clicks on the toolbar go to SwiftUI, drags inside the selection with a tool draw, everything else moves, resizes or redraws the selection (a new selection clears the marks). In Move mode a press on a mark (`Annotation.contains`, topmost first) drags it; the move is one undoable `AnnotationDocument.update`. Marks are previewed with `AnnotationShapeView`. When the overlay opens, `AppState` takes an in-memory snapshot of each display through `CaptureService` (Kropic's windows excluded); blur and pixelate previews are rendered from it with `AnnotationRenderer`, so they look like the final image. Frosted glass (`NSVisualEffectView` behind-window) stands in until the snapshot arrives. The toolbar's action ends the overlay with an `OverlayResult` (selection, marks, `CaptureAction`). `AppState` captures the area, converts the marks to pixels (`Annotation.converted`) and burns them in with `AnnotationRenderer`, then translates, copies (`ImageExporter.copy`), saves (`ImageExporter.save`, `NSSavePanel`, PNG with DPI) or shares (`SharePresenter`, an `NSSharingServicePicker` on a small anchor window, because the overlay sits above menus). Save and Share run after the overlay closes. Blur and pixelate shrink the area to a few samples and scale it back up (smooth for blur, nearest neighbour for pixelate), using Core Graphics only.

**ResultPanel** is a floating, frameless `NSPanel` positioned next to the selection (right, left, below, above) and clamped to the visible frame of that display (`Placement.panelFrame`). Content is SwiftUI in an `NSHostingView` with `sizingOptions = []`: 760 pt wide, at least 440 pt high, taller for long text. The view reports its height (`onGeometryChange`) and `ResultPanel.setHeightKeepingTop` resizes the window itself, keeping the top edge and staying on screen. AppKit's automatic window sizing is not used because it keeps the bottom edge, which pushed the header off the top of the screen. SwiftUI draws the rounded window (radius 12), the draggable header (`WindowDragGesture`) and the footer. The panel handles Esc, ⌘C (all text unless a field has a selection) and ⌘⇧C (translation). A downloadable language pair shows a notice first; only "Download" triggers Apple's prompt (D-037). The view model holds image, extracted text, detected and chosen languages, translation and loading or error state.

## Concurrency

- Everything UI related is `@MainActor`
- OCR and capture run off the main actor and return `Sendable` values
- Cancel in-flight OCR or translation when a new capture starts or the text is edited

## Testing

- KropicCore has unit tests. OCR runs against images rendered in memory with Core Text from known Turkish and English text (no fixture files). Language detection and coordinate conversion have plain unit tests
- UI, permissions and overlay behavior are tested by hand using the checklist at the end of each phase
