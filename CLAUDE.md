# Kropic

Native macOS menu bar app. The user selects a region of the screen, the app extracts the text with OCR and translates it.

Detailed context lives in the files below. They are loaded automatically. Treat them as the source of truth and keep them up to date.

@docs/PRODUCT.md
@docs/ARCHITECTURE.md
@docs/ROADMAP.md
@docs/DECISIONS.md

## Stack

- Swift 6 with strict concurrency checking, SwiftUI first, AppKit where SwiftUI falls short
- Deployment target macOS 15
- Apple frameworks only for core features (ScreenCaptureKit, Vision, Translation, NaturalLanguage)
- One third-party dependency, `sindresorhus/KeyboardShortcuts` via Swift Package Manager
- XcodeGen generates the Xcode project from `project.yml`. Never edit the `.xcodeproj` by hand and never commit it

## Commands

| Task | Command |
|---|---|
| Generate project | `xcodegen generate` |
| Build app | `xcodebuild -project Kropic.xcodeproj -scheme Kropic -configuration Debug build` |
| Test core package | `swift test --package-path Packages/KropicCore` |

Run `xcodegen generate` after any change to `project.yml` or after adding or removing files.

## How we work

- Work one phase at a time from `docs/ROADMAP.md`. Before coding a phase, show a short plan and wait for my approval
- When a phase is done, build it, run the tests, tick its boxes in ROADMAP.md and stop so I can test by hand
- End every phase summary with a "Manual test" checklist for anything you cannot verify yourself (permission prompts, overlay behavior, multiple displays, hotkeys)
- Record every non-obvious decision in `docs/DECISIONS.md` using the format there
- If something in these docs is wrong or impossible with the real API, say so and propose a fix. Do not quietly work around it
- When unsure about an Apple API, check the SDK headers or Apple documentation instead of guessing. APIs in this area changed a lot between macOS 13 and 15

## About me

I am an experienced web developer (React, TypeScript, Vue) and new to Swift. When a Swift or AppKit concept appears for the first time (actors, `@MainActor`, `Sendable`, window levels, NSPanel) explain it in two or three sentences, preferably by comparing it to something from the web world. No long tutorials.

## Code style

- Small focused files, one main type per file
- `@MainActor` for anything touching UI. Services are actors or `Sendable` structs
- Use `@Observable` (Observation framework) for view models, not `ObservableObject`
- No force unwraps outside tests
- Errors are typed enums per module and are shown to the user in plain language

## Design

- The visual spec lives in `design/` (artboards exported from the design canvas, light and dark). Treat it as a spec. Do not port any HTML or CSS
- Build with native SwiftUI controls and system materials. Match spacing, sizes, colors and states from the spec
- Colors live in the asset catalog with Any and Dark appearance variants. Never hardcode hex values in views
- The app supports System, Light and Dark appearance (see PRODUCT.md). Every screen must look right in both
- When a view is done, render its preview to PNG with ImageRenderer in both appearances, save the files to `design/renders/` and compare them with the spec

## Never

- Write captured images to disk
- Add a dependency without asking
- Hardcode a team ID or anything personal in `project.yml`. Signing comes from `Configs/Local.xcconfig`, which is gitignored