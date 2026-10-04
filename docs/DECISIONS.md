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

### D-020 OCR test images rendered in memory
- **Decision** OCR tests draw known text into a `CGImage` with Core Text at test time (`Tests/KropicCoreTests/Support/TestImage.swift`) instead of loading PNG fixtures
- **Why** No binary files in git, the expected text sits next to the image it produces, and there is no risk of committing a real screenshot with personal content
- **Alternatives** Committed PNG fixtures, which would be closer to real screenshots (anti-aliasing, UI chrome) and can still be added later for specific regressions

### D-021 Automatic language detection only for OCR
- **Decision** `RecognizeTextRequest` runs with `automaticallyDetectsLanguage = true` and no explicit `recognitionLanguages`
- **Why** The Turkish test (ç ğ ı İ ö ş ü) passes exactly with automatic detection and language correction on, so a hand-maintained language list adds nothing yet
- **Alternatives** Passing the user's preferred languages plus Turkish and English. Revisit if real captures lose diacritics or mix up scripts

### D-022 Own line and paragraph reconstruction
- **Decision** `TextLayout` in KropicCore rebuilds rows and paragraphs from line positions
- **Why** Vision's paragraph information (`shouldWrapToNextLine`, `transcript`, `RecognizeDocumentsRequest`) needs macOS 26 and the target is macOS 15
- **Alternatives** Using the macOS 26 APIs behind `if #available`, which could also fix multi-column text. A candidate for later

### D-023 One translation path through .translationTask
- **Decision** All translation goes through the SwiftUI `.translationTask` modifier, also on macOS 26
- **Why** `TranslationSession(installedSource:target:)` needs macOS 26 and only works for installed language packs, so it cannot trigger the download prompt. `.translationTask` works on macOS 15 and shows the prompt itself. One path is simpler to test
- **Alternatives** Direct sessions on macOS 26 for installed pairs, with `.translationTask` as a fallback

### D-024 Translating protocol is @MainActor
- **Decision** `Translating` in KropicCore is a `@MainActor` protocol
- **Why** Apple's provider has to be a main-actor object because its session lives in a view. In Swift 6 a main-actor class cannot satisfy nonisolated protocol requirements. A cloud provider can still do its network work off the main actor inside `translate`
- **Alternatives** A nonisolated `Sendable` protocol with an actor-based bridge, which adds complexity for no gain today

### D-025 Session work stays off the main actor
- **Decision** `TranslationHost` passes a `@Sendable` closure to `.translationTask` and calls a `nonisolated` helper that uses the session, hopping to the main actor only to take the queued request and deliver the outcome. `LanguageAvailability` is used in `nonisolated` static helpers
- **Why** Both types are not `Sendable`; using them from the main actor fails strict concurrency checking ("sending 'session' risks causing data races")
- **Alternatives** `@preconcurrency import Translation`, which only turns the errors into warnings and hides a real risk

### D-026 Last target language in UserDefaults
- **Decision** The last chosen target language is stored in `UserDefaults` as a language identifier
- **Why** It is a preference, not captured content, so it does not conflict with D-005. Phase 5 settings can build on the same key
- **Alternatives** Not remembering it, which PRODUCT.md rules out

### D-027 Settings and History as AppKit-hosted windows
- **Decision** One generic `HostingWindowController` opens onboarding, Settings and History. "Settings…" in the menu is enabled (closes D-014)
- **Why** SwiftUI's `Settings` scene opened through `SettingsLink` comes up behind other apps in a menu bar only app. The AppKit pattern from D-012 already activates the app and brings the window forward reliably
- **Alternatives** The SwiftUI `Settings` scene with an activation workaround

### D-028 Default target: "Last used" or a fixed language
- **Decision** The setting offers "Last used" (default) and every supported language. A fixed language is used for every new capture; picking a target in the panel still updates "last used"
- **Why** PRODUCT.md asked for both "defaults to the last one used" and a "Default target language" setting; this keeps both meanings
- **Alternatives** Only "last used", or only a fixed language

### D-029 History as a JSON file, saved when the panel closes
- **Decision** `HistoryStore` writes the newest 20 entries to `History.json` in Application Support (inside the sandbox container). An entry is saved when its result panel closes or is replaced, with the text as the user edited it. A "Save history" setting, on by default, turns this off
- **Why** Simple, text only, testable in KropicCore and reusable on iOS. Saving on close captures the user's edits. OCR text can be sensitive, so users can opt out. Images are never saved (D-005)
- **Alternatives** UserDefaults, SwiftData, or saving as soon as recognition finishes. Known gap: a result still open when Kropic quits is not saved

### D-030 History window copies on click
- **Decision** Clicking a history entry copies its extracted text; the context menu also offers the translation
- **Why** Copying is the main reason to revisit a result, and 20 long entries do not fit a submenu
- **Alternatives** A History submenu, or a list with a detail pane

### D-031 Placeholder app icon from a script
- **Decision** `Scripts/make-placeholder-icon.swift` draws the app icon with plain Core Graphics shapes into the asset catalog. The menu bar keeps the `text.viewfinder` SF Symbol
- **Why** The app needs some icon for Finder, Login Items and its windows. Apple's SF Symbols license does not allow symbols in app icons, so the placeholder draws its own glyph. It is easy to replace with a designed icon later
- **Alternatives** No icon until a designed one exists

### D-032 User-selectable appearance
- **Decision** Settings offers System, Light and Dark. Default is System
- **Why** Some people keep macOS in one mode but want a utility in the other. With asset catalog colors the extra cost is small
- **Alternatives** Follow the system appearance only

### D-033 English UI, strings in a String Catalog
- **Decision** The app's UI language is English. All user facing strings go into `Localizable.xcstrings`; the Turkish copy of the design artboards is translated
- **Why** English is the product decision for now, and a String Catalog lets Turkish be added later without touching views (design/README.md asks for the catalog too)
- **Alternatives** Turkish only, or English and Turkish together right away

### D-034 Fixed brand accent instead of the system accent
- **Decision** Kropic uses the design's accent (#0062CC light, #4BA1FF dark; #0A6CDB for filled buttons in dark) from the asset catalog as its `AccentColor`
- **Why** The design is built around this blue. The user's macOS accent setting no longer recolors Kropic's buttons, which is common for branded utilities
- **Alternatives** Following the system accent color

### D-035 History in a submenu and a window
- **Decision** The menu bar menu gets "Recent Translations" with the last 5 entries (click copies the text) and "Show All…" for the History window from D-030
- **Why** The design has the submenu; the window still serves all 20 entries with copy and context menu
- **Alternatives** Only the submenu, or only the window

### D-036 No pin button for now
- **Decision** The result panel header has capture again and close, but not the design's pin button
- **Why** The panel already floats and stays open; what pinning should change was unclear, so it waits until there is a concrete need
- **Alternatives** Pinned panels that survive the next capture, opening a second panel

### D-037 Language pack notice before Apple's prompt
- **Decision** When a pair is downloadable but not installed, the result panel first shows the design's notice with "Not Now" and "Download". Only "Download" triggers Apple's download prompt
- **Why** The prompt no longer pops up uninvited on the first capture, and the user understands why it appears. Supersedes the immediate prompt from Phase 4
- **Alternatives** Showing Apple's prompt immediately as before

### D-038 Token mapping and generated color symbols
- **Decision** `separator`, `surface` and `toggleOn` from design/README.md map to `separatorColor`, `textBackgroundColor` and the app accent. All other tokens are color sets in `Assets.xcassets` with Any and Dark variants, used through Xcode's generated symbols (`Color.panelBackground`, enabled with `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`)
- **Why** The README prefers semantic colors within a shade of the spec, and the three mapped ones are. Generated symbols make a mistyped color name a compile error instead of an invisible color
- **Alternatives** All tokens in the catalog, or `Color("name")` strings

### D-039 Preview renders through an AppKit snapshot, not ImageRenderer
- **Decision** The debug render harness (`Kropic -renderPreviews`) draws each preview in an off-screen `NSHostingView` and saves an sRGB PNG per appearance. Files land in the sandbox temporary folder and are copied to `design/renders/`
- **Why** `ImageRenderer` replaces native controls (switches, segmented pickers, text fields) with placeholder boxes, so it cannot show what the screens really look like. The snapshot draws them. Known limitation: launched from a terminal the app cannot become active, so AppKit switches render in their inactive grey; SwiftUI buttons are forced active with `controlActiveState`
- **Alternatives** `ImageRenderer` as CLAUDE.md first suggested, or screenshots of the running app, which need Screen Recording permission for the terminal
