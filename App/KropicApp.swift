import SwiftUI

@main
struct KropicApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        MenuBarExtra("Kropic", systemImage: "text.viewfinder") {
            MenuBarContent(appState: appDelegate.appState)
        }
        .menuBarExtraStyle(.menu)
    }
}
