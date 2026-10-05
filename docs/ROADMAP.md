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
- [x] Appearance setting (System, Light, Dark) through AppearanceService (built in Phase 6, see there)
- [x] App icon and menu bar icon (placeholder app icon from `Scripts/make-placeholder-icon.swift`, SF Symbol in the menu bar; final icon to come)

## Phase 6 — Apply design
Spec: `design/screens/` (light and dark PNGs) and `design/source/` (HTML with exact values).
- [x] Color tokens in the asset catalog (Any and Dark), fixed accent, type and spacing constants, AppearanceService, preview render harness
- [x] String Catalog with all user facing strings in English
- [x] Shared components (section label, chip, text button, primary and secondary buttons, field, status card, footer)
- [x] Result panel shell: custom header and footer, 760 pt wide layout, image column with caption, grows for long text
- [x] Result panel states: main, loading with placeholder bars, no text, language pack notice (notice first, then Apple's prompt)
- [x] Result panel features: swap languages, capture again, ⌘C and ⌘⇧C
- [x] Selection overlay: dim, outline, handles, size label, cancel and confirm bar, hint pill
- [x] Onboarding window with numbered steps and "Not Now"
- [x] Settings window: sections and order from the spec, subtitles, Appearance picker, footer note
- [x] Menu bar: crop icon, Recent Translations submenu, About Kropic
- [x] History window restyled with the tokens (no design screen)
- [x] Placeholder app icon redrawn with the crop glyph
- [x] Final app icon and menu bar glyph from `design/icon/`, app icon as an Icon Composer `.icon` for the macOS 26 Liquid Glass look

Done when every screen matches its design in light and dark mode.

## Phase 7 — Annotate and share
- [x] Annotation model, undo/redo and renderer in KropicCore with tests (arrow, rectangle, text, highlight, blur, pixelate)
- [x] Annotation editor window opened from the result panel header: tools, colors, undo and redo
- [x] Copy the annotated image to the clipboard and share it through the macOS share menu

Settled: annotation happens after capture in an editor window (D-048); sharing amends D-005 (D-049). Superseded by Phase 8 after testing: the editor window was removed, the core model and renderer stay.

## Phase 8 — Capture toolbar: annotate, then copy, save, share or translate
- [x] Capture toolbar under the selection: Move, annotation tools, colors, undo and redo, Copy, Save, Share, Translate, cancel
- [x] Drawing on the selection in the overlay with live previews; marks converted to image pixels at capture (tested in KropicCore)
- [x] Copy Image to the clipboard, Save Image as PNG to a user-chosen location, Share through the macOS share menu
- [x] Translate reads the annotated image; the result panel shows it
- [x] Keyboard: V and A R T H B P tools, ⌘Z, ⇧⌘Z, ⌘C, ⌘S, Enter, Esc
- [x] Phase 7 editor window and header button removed
- [x] Move, delete and recolor marks after drawing; freehand pencil; live blur and pixelate from an in-memory screen snapshot; clearer tool icons and per-tool hints
