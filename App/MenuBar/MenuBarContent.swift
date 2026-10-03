import KeyboardShortcuts
import SwiftUI

struct MenuBarContent: View {
    let appState: AppState

    var body: some View {
        Button("Capture Text") {
            appState.startCapture()
        }
        .globalKeyboardShortcut(.captureText)

        // Placeholder until the Settings window lands in Phase 5.
        Button("Settings…") {}
            .disabled(true)

        Divider()

        Button("Quit Kropic") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
