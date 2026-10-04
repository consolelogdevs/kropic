import SwiftUI

@main
struct KropicApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(appState: appDelegate.appState)
        } label: {
            // A template image: macOS tints it for light and dark menu bars.
            Image(.menuBarIcon)
                .accessibilityLabel("Kropic")
        }
        .menuBarExtraStyle(.menu)
    }
}
