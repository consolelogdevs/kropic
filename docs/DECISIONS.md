# Decisions

Newest at the bottom. Format for each entry is the title line followed by Decision, Why and Alternatives.

### D-001 Native Swift instead of Electron or Tauri
- **Decision** Swift with SwiftUI and AppKit
- **Why** Screen capture, OCR and translation are all native Apple frameworks. A native app stays small and fast and keeps an iOS version possible
- **Alternatives** Electron or Tauri would reuse web skills but need native bridges for every core feature

### D-002 Apple frameworks for OCR and translation
- **Decision** Vision for OCR, Translation framework for translation
- **Why** Free, on-device, private, works offline
- **Alternatives** Google, DeepL or Claude APIs. Possibly added later behind the `Translating` protocol

### D-003 macOS 15 minimum
- **Decision** Deployment target macOS 15
- **Why** The Translation framework and the newer Swift Vision API need it
- **Alternatives** macOS 14 would mean dropping on-device translation

### D-004 XcodeGen
- **Decision** Generate the Xcode project from `project.yml`
- **Why** Readable diffs and no hand-edited project files, which matters when an AI agent edits the project
- **Alternatives** Plain Xcode project or Tuist

### D-005 Images stay in memory
- **Decision** Captured images are never written to disk. History keeps text only
- **Why** Privacy. Screenshots often contain sensitive content
- **Alternatives** Saving images for history

### D-006 App Sandbox on from the start
- **Decision** Enable App Sandbox in Phase 0
- **Why** Keeps the Mac App Store option open. Turning it on late usually breaks things
- **Alternatives** No sandbox with direct distribution only

### D-007 Swift Testing instead of XCTest
- **Decision** KropicCore tests use Swift Testing (`import Testing`, `@Test`, `#expect`)
- **Why** Modern Apple test framework, less boilerplate, parameterized tests are handy for OCR fixtures
- **Alternatives** XCTest, which still works but is the older API

### D-008 Bundle ID prefix comes from Local.xcconfig
- **Decision** `PRODUCT_BUNDLE_IDENTIFIER = $(BUNDLE_ID_PREFIX).kropic`. Base.xcconfig sets a neutral default `app.kropic`, `Local.xcconfig` may override it
- **Why** Keeps anything personal out of committed files while letting each developer sign with their own ID
- **Alternatives** Hardcoding a reverse-DNS ID in `project.yml`

### D-009 Explicit @MainActor, no default actor isolation
- **Decision** The app target keeps Swift's default `nonisolated` isolation. UI types are marked `@MainActor` explicitly
- **Why** Matches the code style rule and makes isolation visible in each file. Xcode 26 offers `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, which hides it
- **Alternatives** MainActor-by-default for the app target

### D-010 KeyboardShortcuts 3.x
- **Decision** Depend on `sindresorhus/KeyboardShortcuts` `from: 3.1.0`
- **Why** Latest major at setup time, supports Swift 6 and macOS 10.15+
- **Alternatives** 2.x, which is older with no benefit for us

### D-011 AppDelegate starts AppState
- **Decision** `AppState` is owned by an `NSApplicationDelegate` (via `@NSApplicationDelegateAdaptor`) and started in `applicationDidFinishLaunching`
- **Why** The hotkey must be registered at launch, not when the menu is first opened, and opening the onboarding window inside `App.init` is too early
- **Alternatives** Creating `AppState` as `@State` in the `App` struct and starting it from a view's `.task`, which only runs once the menu is opened

### D-012 Onboarding window is AppKit-hosted
- **Decision** `OnboardingWindowController` creates an `NSWindow` with an `NSHostingController` for the SwiftUI view
- **Why** SwiftUI's `openWindow` is only reachable from inside a view, and the hotkey path has none. A menu bar only app also has to call `NSApp.activate()` itself to bring the window forward
- **Alternatives** A SwiftUI `Window` scene opened through `openWindow`

### D-013 Capture triggers on key up
- **Decision** The global shortcut fires on key up
- **Why** By the time the overlay appears in Phase 2, ⌘ and ⇧ are released, so they cannot change the first click or drag
- **Alternatives** Key down, which feels slightly faster

### D-014 Settings menu item disabled until Phase 5
- **Decision** "Settings…" is a disabled placeholder
- **Why** A real Settings window in a menu bar only app needs a workaround to come to the front. Solving it once, together with real content, is cheaper
- **Alternatives** An empty SwiftUI `Settings` scene opened with `SettingsLink`

### D-015 Capture through a content filter, not captureImage(in:)
- **Decision** Capture with `SCScreenshotManager.captureImage(contentFilter:configuration:)`, a display filter that excludes Kropic's own app, and `sourceRect` set to the selection
- **Why** `captureImage(in:)` needs macOS 15.2 (target is 15.0) and cannot exclude windows. Excluding our app means the overlay never appears in the image and does not have to be hidden first
- **Alternatives** `captureImage(in:)` behind an availability check, hiding the overlay and waiting a frame before capturing

### D-016 Activate Kropic during selection, restore focus afterwards
- **Decision** Kropic activates itself when the overlay opens and re-activates the previously frontmost app on cancel or when the result panel closes (`FocusRestorer`). Overlay hosting views accept the first click
- **Why** The first attempt used `.nonactivatingPanel` panels so the user's app would stay active. In manual testing the overlay appeared but SwiftUI received no mouse or hover events while Kropic was inactive, so nothing could be drawn
- **Alternatives** Non-activating panels with AppKit mouse handling instead of SwiftUI gestures

### D-017 Every display dims, outside drag starts a new selection
- **Decision** All displays get an overlay. The selection lives on the display where the drag starts. Dragging outside an existing selection replaces it, a click without dragging clears it, and only Esc cancels
- **Why** Matches macOS's own screenshot tool and most capture apps, so it feels familiar
- **Alternatives** Only the display under the cursor dims; a click outside cancels

### D-018 Pure geometry lives in KropicCore
- **Decision** Coordinate conversion, selection math (normalise, clamp, move, resize, hit testing) and placement (confirm button, result panel) live in `KropicCore/Geometry`
- **Why** The app target has no test target. These functions only need CoreGraphics, are easy to get wrong (negative display origins, flipped y) and are fully unit-testable there
- **Alternatives** Keeping them in the app target and adding an app test target

### D-019 Overlay mouse input through AppKit, panel never click-through
- **Decision** The overlay panel sets `ignoresMouseEvents = false` explicitly and reads mouse down, drag and up in `sendEvent`, forwarding display-local points to `SelectionModel`. Esc and Enter come from an app-wide local key monitor while the overlay is open. SwiftUI only draws and sets the cursor
- **Why** A transparent window lets clicks through wherever the window server sees no content, and SwiftUI's layers do not count, so the overlay was entirely click-through (found with diagnostics in manual testing). Handling input in AppKit also removes any doubt about SwiftUI gestures in a borderless panel
- **Alternatives** SwiftUI `DragGesture` and `onKeyPress`, which would likely also work once the panel is not click-through
