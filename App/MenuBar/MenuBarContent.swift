import KeyboardShortcuts
import SwiftUI

struct MenuBarContent: View {
    let appState: AppState

    var body: some View {
        Button("Capture Text") {
            appState.startCapture()
        }
        .globalKeyboardShortcut(.captureText)

        Button("History…") {
            appState.showHistory()
        }

        Button("Settings…") {
            appState.showSettings()
        }
        .keyboardShortcut(",")

        Divider()

        Button("Quit Kropic") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
