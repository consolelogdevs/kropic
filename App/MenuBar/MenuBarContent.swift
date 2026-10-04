import KeyboardShortcuts
import SwiftUI

/// The menu bar menu in the spec's order. A real `NSMenu`, drawn by macOS.
struct MenuBarContent: View {
    let appState: AppState

    var body: some View {
        Button("Capture Text") {
            appState.startCapture()
        }
        .globalKeyboardShortcut(.captureText)

        Divider()

        RecentTranslationsMenu(history: appState.history) {
            appState.showHistory()
        }

        Divider()

        Button("Settings…") {
            appState.showSettings()
        }
        .keyboardShortcut(",")

        Button("About Kropic") {
            appState.showAbout()
        }

        Divider()

        Button("Quit Kropic") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
