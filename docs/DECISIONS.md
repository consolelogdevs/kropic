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

### D-040 String Catalogs synced by a script
- **Decision** `App/Resources/Localizable.xcstrings` for the app and a second catalog inside KropicCore (`defaultLocalization: "en"`, `bundle: .module`). `Scripts/sync-strings.sh` builds and runs `xcstringstool sync` on the compiler's `.stringsdata`, skipping debug-only preview views
- **Why** Xcode fills catalogs on build only in the IDE; `xcodebuild` emits the strings but never writes them back. A Swift package needs its own catalog to localize its error messages
- **Alternatives** Relying on opening the project in Xcode, or moving KropicCore's user facing messages into the app target

### D-041 Frameless result panel that grows downward
- **Decision** The result panel is a borderless `NSPanel` whose SwiftUI content draws the rounded window, header and footer. The SwiftUI view reports its height and `ResultPanel.setHeightKeepingTop` resizes the window with the top edge fixed, never taller than the screen and moved up only as far as needed. The hosting view's automatic window sizing is off (`sizingOptions = []`). Text areas grow up to 200 pt and then scroll
- **Why** The design has its own 44 pt header instead of a title bar and a 12 pt corner radius. Growing downward keeps the panel next to the selection it belongs to
- **Alternatives** A titled panel with a hidden, transparent title bar, whose corner radius and traffic lights follow the system instead of the spec. Letting `NSHostingView` size the window was tried first: AppKit kept the bottom edge, so long text pushed the header off the top of the screen (found in manual testing)

### D-042 Full-width language pickers only on macOS 26
- **Decision** The language pop-ups use `.buttonSizing(.flexible)` on macOS 26 so they fill their half of the row like the spec. On macOS 15 they keep the native intrinsic width
- **Why** The modifier only exists from macOS 26, and design/README.md says the native pop-up look wins over the artboard
- **Alternatives** A custom `Menu` drawn like the spec's select on every version

### D-043 Extra token for muted boxes
- **Decision** `mutedBackground` (#EEEEF0 light, #2C2C2E dark) joins the asset catalog for translation states without a translation, such as "Translation starts automatically when the text is ready"
- **Why** The Loading artboard uses this color, but design/README.md's token table does not list it
- **Alternatives** Reusing `chipBackground`, which is darker in dark mode

### D-044 Overlay always in the light appearance, hint for 3 uses
- **Decision** Overlay panels set `appearance = .aqua`, so their tokens (accent, accent fill) always resolve to the light values. The hint pill shows during the first 3 overlays, counted in `AppSettings.overlayUses`, on the display under the cursor only
- **Why** design/README.md specifies one overlay look for both themes, since it always sits over a dimmed screen. "First few uses" needed a number; 3 is enough to learn four gestures without nagging
- **Alternatives** Separate fixed color constants for the overlay, or a hint that never goes away

### D-045 Hint pill on every capture
- **Decision** The overlay's hint pill shows on every capture, on the display under the cursor. The first-use counter from D-044 is removed
- **Why** Product decision after testing: the gestures stay discoverable at all times. Overrides design/README.md's "shown only on the first few uses"
- **Alternatives** Showing it only on the first 3 uses (D-044), or a setting to hide it

### D-046 Crop glyph for the menu bar and the placeholder icon
- **Decision** The menu bar uses the `crop` SF Symbol. `Scripts/make-placeholder-icon.swift` now draws the same crop shape in white on the design's accent blue, with Core Graphics paths. Supersedes the viewfinder glyph from D-031
- **Why** The design uses the crop glyph in the menu bar, the result panel header and the onboarding tile. SF Symbols may be used in the menu bar but not in app icons, so the icon draws the shape itself
- **Alternatives** Keeping the viewfinder until the final icon arrives

### D-047 Final app icon and Kropic glyph
- **Decision** `AppIcon.appiconset` and `MenuBarIcon.imageset` come from `design/icon/` (concept "A · crop corners"). The menu bar label is the vector `MenuBarIcon` as a template image. The same glyph replaces the `crop` SF Symbol as the brand mark in the result panel header (accent tint) and on the onboarding tile (white on the accent fill). The header's capture-again button keeps the `crop` SF Symbol because it is an action, not the logo. `Scripts/make-placeholder-icon.swift` is removed. Supersedes D-031 and D-046
- **Why** The designed icon replaces the placeholder. A template image lets macOS tint the glyph for light and dark menu bars, and using one glyph everywhere ties the menu bar, panel and onboarding to the app icon. On the onboarding tile an accent tint would vanish on the accent background, so the glyph is white there. design/icon/README.md asks to check the Dock, but Kropic is a menu bar only app (`LSUIElement`) and has no Dock icon; Finder, the About panel and Login Items show the app icon instead
- **Alternatives** Keeping SF Symbols in the app UI, or building an Icon Composer `.icon` now (planned before an App Store release, for the macOS 26 Liquid Glass look)

### D-048 Annotate after capture, in an editor window
- **Decision** An Annotate button in the result panel header opens an editor window for the captured image, instead of drawing tools on the selection overlay before confirming
- **Why** On the overlay every drag already draws, moves or resizes the selection, so drawing tools there would give the same gesture two meanings. The result panel already holds the image in memory, and a window gives room for a toolbar, undo and share
- **Alternatives** A toolbar on the selection like macOS's own screenshot tool, as the roadmap first suggested

### D-049 Sharing amends D-005
- **Decision** Kropic itself still never writes captured images to disk. "Share…" hands the annotated image to macOS at the user's request; share targets such as Mail or AirDrop may store their own temporary copy. "Copy Image" uses the clipboard only
- **Why** Sharing is the point of Phase 7 and only ever happens on an explicit user action. Blur and pixelate let users hide sensitive content first
- **Alternatives** Copy to clipboard only, with no share menu

### D-050 Blur and pixelate with Core Graphics only
- **Decision** Both shrink the marked area to a few samples and scale it back up: with smoothing for blur (about 6 samples across the shorter side), without it for pixelate (blocks of an eighth of the shorter side, at least 8 px). No Core Image
- **Why** KropicCore stays on frameworks available on macOS and iOS without image filters, and the result is deterministic and testable. The strength is chosen so text underneath cannot be read; tests check that fine stripes disappear
- **Alternatives** Core Image's Gaussian blur and pixellate filters, which would add a framework to the core and need a stronger setting to be safe against unblurring

### D-051 Annotations drawn by one renderer
- **Decision** `AnnotationRenderer` in KropicCore draws committed annotations into a copy of the image in image pixels (origin top-left). The editor shows that composite and only previews the shape being dragged with SwiftUI shapes. Copy and Share use the same composite
- **Why** One drawing path means the shared image matches the screen exactly, and it is unit-testable by reading pixels. The original capture is never modified, so OCR and translation stay on the clean image
- **Alternatives** Drawing annotations with SwiftUI on screen and separately for export

### D-052 Save Image to a user-chosen location
- **Decision** Save Image writes a PNG only to the location picked in the standard Save dialog. The app gets `com.apple.security.files.user-selected.read-write`, which only covers files the user picks. Amends D-005 and D-049: Kropic writes a captured image to disk only on an explicit Save
- **Why** Saving annotated captures is a core use case of the capture toolbar. A user-picked location keeps the privacy promise meaningful: nothing is stored silently, and history stays text only
- **Alternatives** Saving automatically to a fixed folder like macOS screenshots, or no Save at all

### D-053 Text recognition reads the annotated image
- **Decision** Marks are burned into the captured image before anything else; Translate runs OCR on that image and the result panel shows it
- **Why** Blurred or pixelated text must not be extracted, or redaction would leak. The cost is that an arrow or highlight drawn over text can slightly disturb recognition
- **Alternatives** OCR on the clean image, which ignores redactions

### D-054 Capture toolbar replaces the annotation editor window
- **Decision** Annotation moves into the selection overlay with a capture toolbar (Move, tools, colors, undo/redo, Copy, Save, Share, Translate, cancel). Move is the default; with a tool selected, drags inside the selection draw and the selection handles hide. Save and Share run after the overlay closes because the overlay sits above dialogs and menus. Supersedes D-048; the Phase 7 editor window is removed, `Annotation`, `AnnotationDocument` and `AnnotationRenderer` are reused
- **Why** Manual testing showed the editor-after-capture flow was not what users expect: annotating, saving and sharing belong to the moment of capture, like macOS's own screenshot tool. Separating Move and drawing modes keeps the one-gesture-one-meaning rule from D-048's reasoning
- **Alternatives** Keeping the editor window, or a toolbar that always draws with modifier keys for moving

### D-055 Moving marks in Move mode
- **Decision** In Move mode a press on a mark selects and drags it; a press elsewhere moves or resizes the selection. The selected mark has a dashed outline, Delete removes it and choosing a color recolors it. A move is one undo step. Drawing tools always draw, even over existing marks
- **Why** Manual testing asked for repositioning marks. Keeping it in Move mode keeps one meaning per gesture: drawing over a mark (for example a pencil circle around an arrow) never moves it by accident
- **Alternatives** Moving a mark whenever a press lands on it with any tool, which makes drawing over marks unreliable

### D-056 Live blur and pixelate from an in-memory snapshot
- **Decision** When the overlay opens, each display is captured once into memory (Kropic's windows excluded). Blur and pixelate previews crop that snapshot and run the same `AnnotationRenderer` as the final image, so the preview matches the result. The snapshot is never written anywhere and is dropped with the overlay. The final image is still captured fresh when an action is chosen
- **Why** Manual testing found the frosted-glass preview misleading; users should see exactly what will be hidden. Rendering from a snapshot is the only way to show real pixels under a transparent overlay
- **Alternatives** Frosted glass only (D-054's first version), or freezing the screen and using the snapshot as the final image

### D-057 App icon from Icon Composer
- **Decision** The app icon is `App/Resources/Kropic.icon`, made in Icon Composer from `design/icon/source/layers/` (background and foreground SVGs). `ASSETCATALOG_COMPILER_APPICON_NAME` is `Kropic`. `actool` compiles it into layered icon images for macOS 26 and a flat `Kropic.icns` fallback for macOS 15, so the PNG `AppIcon.appiconset` is removed from the catalog (it stays in `design/icon/` as source). XcodeGen registers the package as one resource (`wrapper.icon`), which `actool` accepts
- **Why** macOS 26 renders Icon Composer icons with Liquid Glass, light and dark variants and system tinting; a PNG set looks flat next to system apps. The generated fallback keeps macOS 15 covered without maintaining two icon sources
- **Alternatives** Keeping only the PNG icon set, or both with the PNG set as an explicit fallback
- **Note** After the switch Finder and the About panel showed an empty icon: a running app and Finder keep the icon they loaded first. Quitting the app, `lsregister -f` on the bundle and `killall Finder` fixed it; the build itself was correct

### D-058 Open source first, notarized builds later
- **Decision** Kropic is published as source under MIT at `ecsabanci/kropic`. Users clone and build it themselves (README, `Scripts/install.sh`). A clean clone builds without personal settings through Xcode's ad-hoc "Sign to Run Locally"; signing with any Apple ID (`Configs/Local.xcconfig`) keeps the screen recording permission across rebuilds. The private `design/` folder was removed from the entire git history before the first push and is git-ignored. Author email stays in commits by choice
- **Why** Building from source needs no notarization, so interest can be tested without the paid Apple Developer Program. The design artboards are the owner's private work; only the product is shared
- **Alternatives** Notarized `.dmg` releases right away (paid program), or shipping unsigned binaries, which macOS blocks
