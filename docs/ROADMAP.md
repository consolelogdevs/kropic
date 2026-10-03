# Roadmap

Work one phase at a time. Tick a box only when it is done and verified. Stop at the end of each phase.

## Phase 0 — Project setup
- [x] `project.yml` with the app target, KropicCore local package and KeyboardShortcuts dependency
- [x] `Configs/Base.xcconfig`, `Configs/Local.example.xcconfig` and `.gitignore` (ignores `Local.xcconfig`, `*.xcodeproj`, build folders)
- [x] App runs as menu bar only (`LSUIElement`), App Sandbox enabled
- [x] KropicCore skeleton with one passing test

Done when `xcodegen generate` and the build command succeed, the app shows an icon in the menu bar with a Quit item and there is no Dock icon.

## Phase 1 — Menu bar, hotkey, permission
- [ ] Menu with "Capture Text", "Settings…" (placeholder) and "Quit"
- [ ] Global shortcut ⌘⇧2 triggers the same action as "Capture Text"
- [ ] Screen Recording check before capture. Onboarding window when missing, with the System Settings link and restart button

Done when the shortcut and the menu item both reach the capture entry point and the onboarding appears when permission is missing.

## Phase 2 — Selection overlay and capture
- [ ] Overlay on the display under the cursor with dim layer and crosshair
- [ ] Draw, move and resize the selection. Size label
- [ ] Checkmark button and Enter confirm. Esc and outside click cancel
- [ ] Capture the region with ScreenCaptureKit, excluding Kropic's windows
- [ ] Result panel opens next to the selection and shows the image

Done when captures are pixel-accurate on a Retina display and on an external display.

## Phase 3 — OCR
- [ ] TextRecognizer in KropicCore with fixture-based tests (Turkish and English)
- [ ] Extracted text shown in the panel, editable, with a copy button
- [ ] Loading state and "No text found" state

## Phase 4 — Language detection and translation
- [ ] LanguageDetector in KropicCore with tests
- [ ] Source and target pickers, last target remembered
- [ ] AppleTranslationProvider behind the `Translating` protocol
- [ ] Auto-translate when languages differ, debounced re-translate on edit
- [ ] Language pack download prompt and unsupported pair message

## Phase 5 — Polish
- [ ] Settings window (see PRODUCT.md)
- [ ] History of the last 20 results, text only
- [ ] Launch at login with `SMAppService`
- [ ] App icon and menu bar icon
