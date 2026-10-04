# Product

## What it is

A small, fast menu bar utility. Press a shortcut, select any text on screen (in an image, a video, a locked PDF, an app that does not allow copying), get the text and its translation next to it. Inspired by Huawei Translate on Windows.

## Core user flow

1. **Trigger** — The user clicks the menu bar icon or presses the global shortcut (default ⌘⇧2, configurable in Settings)
2. **Select** — Every display dims and the cursor becomes a crosshair. The user drags to draw a selection rectangle. A small label shows the selection size
3. **Adjust** — After the mouse is released the selection stays editable. It can be moved by dragging inside and resized from its edges and corners
4. **Confirm** — A small bar with a cancel (×) and a confirm (✓) button sits below the bottom right corner of the selection (or above it if there is no room). Clicking ✓ or pressing Enter confirms, × cancels. A hint pill at the top of the screen explains the gestures on every capture. Esc cancels and closes the overlay. Dragging outside the selection starts a new one, and a click without dragging clears it. The selection stays on the display where the drag started
5. **Result panel** — A floating panel opens near the selected area. Its header shows the selection size and buttons to capture again and close; its footer shows keyboard hints and that translation runs on the device
   - Left side shows the captured image
   - Right side shows the extracted text, editable, with a copy button
   - Below it sit the source and target language pickers with a swap button between them, and the translation, also with a copy button
   - ⌘C copies the extracted text and ⌘⇧C copies the translation when no text is selected in a field
6. **Translate** — Source language is detected automatically and can be overridden. Target language defaults to the last one used (first run uses the system language, falling back to English). If source and target differ, translation runs automatically. Editing the extracted text re-translates after a short debounce
7. **Close** — Esc or the close button closes the panel. The panel stays on top of other windows but does not steal focus aggressively

## Empty and error states

- No text found → show "No text found in the selected area" with a short hint and two buttons, Close and Capture Again
- Screen Recording permission missing → show onboarding (see below) instead of the overlay
- Language pack not downloaded → show a notice naming the language pair with "Not Now" and "Download". Download opens Apple's download prompt. The extracted text stays available either way
- Language pair not supported → say so plainly and keep the extracted text

## Onboarding

First launch shows a small window that explains in one or two sentences why Screen Recording permission is needed, with a button that opens the right page in System Settings. macOS often requires the app to restart after the permission is granted. The onboarding shows three numbered steps, a "Not Now" and an "Open System Settings" button, and a link "I've allowed it, restart Kropic".

On macOS 15 and later the System Settings page is named **Screen & System Audio Recording** (Privacy & Security). User-facing text uses that name.

## Appearance

Every window and panel exists in a light and a dark version. By default Kropic follows the macOS setting. The user can force Light or Dark in Settings and the change applies to all open windows instantly. The selection overlay looks the same in both, since it always sits on top of a dimmed screen.

## Settings (Phase 5)

- Global shortcut
- Default target language: "Last used" (default) or a fixed language used for every new capture
- Translate automatically on or off. When off, the panel shows a Translate button
- Copy extracted text to clipboard automatically on or off
- Launch at login
- Appearance (System, Light or Dark), applied immediately without a restart. Default is System
- Save history on or off (on by default)
- Clear history

## History (Phase 5)

The last 20 results, text only (extracted text as edited, translation, languages, date). Images are never stored. A result is saved when its panel closes or a new capture replaces it, and only when "Save history" is on. The menu bar menu has a "Recent Translations" submenu with the last 5 entries (clicking one copies its text) and "Show All…", which opens the History window. In the window, clicking an entry copies its extracted text, and a context menu also copies the translation.

## Language

The UI is in English. Every user facing string lives in a String Catalog (`Localizable.xcstrings`) so Turkish and other languages can be added later. The design artboards are in Turkish; their copy is translated to English.

## Annotate and share (Phase 7)

The result panel header has an Annotate button. It opens an editor window with the captured image and these tools: arrow, rectangle, text, highlight, blur and pixelate, five colors (red, yellow, blue, black, white), and undo and redo (⌘Z, ⇧⌘Z). Blur and pixelate make the text under them unreadable, for hiding sensitive content before sharing. "Copy Image" puts the annotated image on the clipboard; "Share…" opens the macOS share menu. The extracted text and translation always come from the original image. Annotations live in memory only and are gone when the editor closes.

## Not in v1

- Cloud translation providers (the architecture must allow adding them later)
- iOS app (the core package must allow it later)
- Continuous or live translation of a screen area
- Text-to-speech, dictionary lookups, accounts or sync
