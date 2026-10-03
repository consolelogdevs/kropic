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

### D-007 User-selectable appearance
- **Decision** Settings offers System, Light and Dark. Default is System
- **Why** Some people keep macOS in one mode but want a utility in the other. With asset catalog colors the extra cost is small
- **Alternatives** Follow the system appearance only