import SwiftUI

@main
struct KropicApp: App {
    var body: some Scene {
        MenuBarExtra("Kropic", systemImage: "text.viewfinder") {
            Button("Quit Kropic") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)
    }
}
