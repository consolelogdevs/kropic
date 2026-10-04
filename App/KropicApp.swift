import SwiftUI

@main
struct KropicApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        MenuBarExtra("Kropic", systemImage: "crop") {
            MenuBarContent(appState: appDelegate.appState)
        }
        .menuBarExtraStyle(.menu)
    }
}
