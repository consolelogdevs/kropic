# Product

## What it is

A small, fast menu bar utility. Press a shortcut, select any text on screen (in an image, a video, a locked PDF, an app that does not allow copying), get the text and its translation next to it. Inspired by Huawei Translate on Windows.

## Core user flow

1. **Trigger** — The user clicks the menu bar icon or presses the global shortcut (default ⌘⇧2, configurable in Settings)
2. **Select** — The screen under the cursor dims and the cursor becomes a crosshair. The user drags to draw a selection rectangle. A small label shows the selection size
3. **Adjust** — After the mouse is released the selection stays editable. It can be moved by dragging inside and resized from its edges and corners
4. **Confirm** — A small checkmark button sits at the bottom right corner of the selection (or above it if there is no room). Clicking it or pressing Enter confirms. Esc or a click outside cancels and closes the overlay
5. **Result panel** — A floating panel opens near the selected area
   - Left side shows the captured image
   - Right side shows the extracted text, editable, with a copy button
   - Below it sit the source and target language pickers and the translation, also with a copy button
6. **Translate** — Source language is detected automatically and can be overridden. Target language defaults to the last one used (first run uses the system language, falling back to English). If source and target differ, translation runs automatically. Editing the extracted text re-translates after a short debounce
7. **Close** — Esc or the close button closes the panel. The panel stays on top of other windows but does not steal focus aggressively

## Empty and error states

- No text found → show "No text found in the selected area" with a button to try again
- Screen Recording permission missing → show onboarding (see below) instead of the overlay
- Language pack not downloaded → show Apple's download prompt. If the user declines, keep the extracted text and explain why translation is missing
- Language pair not supported → say so plainly and keep the extracted text

## Onboarding

First launch shows a small window that explains in one or two sentences why Screen Recording permission is needed, with a button that opens the right page in System Settings. macOS often requires the app to restart after the permission is granted. The onboarding says this and offers a "Restart Kropic" button.

## Appearance

Every window and panel exists in a light and a dark version. By default Kropic follows the macOS setting. The user can force Light or Dark in Settings and the change applies to all open windows instantly. The selection overlay looks the same in both, since it always sits on top of a dimmed screen.

## Settings (Phase 5)

- Global shortcut
- Default target language
- Auto-translate on or off
- Copy extracted text to clipboard automatically on or off
- Launch at login
- Appearance (System, Light or Dark), applied immediately without a restart. Default is System
- Clear history

## History (Phase 5)

The last 20 results, text only (extracted text, translation, languages, date). Images are never stored. Reachable from the menu bar menu.

## Not in v1

- Cloud translation providers (the architecture must allow adding them later)
- iOS app (the core package must allow it later)
- Continuous or live translation of a screen area
- Text-to-speech, dictionary lookups, accounts or sync