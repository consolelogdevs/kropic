# Roadmap

Work one phase at a time. Tick a box only when it is done and verified. Stop at the end of each phase.

## Phase 0 — Project setup
- [x] `project.yml` with the app target, KropicCore local package and KeyboardShortcuts dependency
- [x] `Configs/Base.xcconfig`, `Configs/Local.example.xcconfig` and `.gitignore` (ignores `Local.xcconfig`, `*.xcodeproj`, build folders)
- [x] App runs as menu bar only (`LSUIElement`), App Sandbox enabled
- [x] KropicCore skeleton with one passing test

Done when `xcodegen generate` and the build command succeed, the app shows an icon in the menu bar with a Quit item and there is no Dock icon.

## Phase 1 — Menu bar, hotkey, permission
- [x] Menu with "Capture Text", "Settings…" (placeholder) and "Quit"
- [x] Global shortcut ⌘⇧2 triggers the same action as "Capture Text"
- [x] Screen Recording check before capture. Onboarding window when missing, with the System Settings link and restart button

Done when the shortcut and the menu item both reach the capture entry point and the onboarding appears when permission is missing.

## Phase 2 — Selection overlay and capture
- [x] Overlay on every display with dim layer and crosshair
- [x] Draw, move and resize the selection. Size label
- [x] Checkmark button and Enter confirm. Esc cancels, dragging outside starts a new selection
- [x] Capture the region with ScreenCaptureKit, excluding Kropic's windows
- [x] Result panel opens next to the selection and shows the image

Done when captures are pixel-accurate on a Retina display and on an external display.

## Phase 3 — OCR
- [x] TextRecognizer in KropicCore with tests on rendered Turkish and English text
- [x] Extracted text shown in the panel, editable, with a copy button
- [x] Loading state and "No text found" state

## Phase 4 — Language detection and translation
- [x] LanguageDetector in KropicCore with tests
- [x] Source and target pickers, last target remembered
- [x] AppleTranslationProvider behind the `Translating` protocol
- [x] Auto-translate when languages differ, debounced re-translate on edit
- [x] Language pack download prompt and unsupported pair message

## Phase 5 — Polish
- [x] Settings window (see PRODUCT.md)
- [x] History of the last 20 results, text only
- [x] Launch at login with `SMAppService`
- [ ] Appearance setting (System, Light, Dark) through AppearanceService (built in Phase 6, see there)
- [x] App icon and menu bar icon (placeholder app icon from `Scripts/make-placeholder-icon.swift`, SF Symbol in the menu bar; final icon to come)

## Phase 6 — Apply design
Spec: `design/screens/` (light and dark PNGs) and `design/source/` (HTML with exact values).
- [x] Color tokens in the asset catalog (Any and Dark), fixed accent, type and spacing constants, AppearanceService, preview render harness
- [x] String Catalog with all user facing strings in English
- [ ] Shared components (section label, chip, text button, primary and secondary buttons, field, status card, footer)
- [ ] Result panel shell: custom header and footer, 760 pt wide layout, image column with caption, grows for long text
- [ ] Result panel states: main, loading with placeholder bars, no text, language pack notice (notice first, then Apple's prompt)
- [ ] Result panel features: swap languages, capture again, ⌘C and ⌘⇧C
- [ ] Selection overlay: dim, outline, handles, size label, cancel and confirm bar, hint pill on first uses
- [ ] Onboarding window with numbered steps and "Not Now"
- [ ] Settings window: sections and order from the spec, subtitles, Appearance picker, footer note
- [ ] Menu bar: crop icon, Recent Translations submenu, About Kropic
- [ ] History window restyled with the tokens (no design screen)
- [ ] Placeholder app icon redrawn with the crop glyph

Done when every screen matches its design in light and dark mode.

## Phase 7 — Annotate and share (after v1, not yet planned in detail)
- [ ] Toolbar on the selection before confirming: arrow, rectangle, text, highlight, undo
- [ ] Annotations are drawn onto the captured image in memory
- [ ] Copy the annotated image to the clipboard and share it through the macOS share menu

Open questions to settle before planning: annotate in the overlay (before ✓) or in the result panel (after capture); whether sharing fits the "images never touch disk" rule (D-005), since some share targets may write files on their side.
