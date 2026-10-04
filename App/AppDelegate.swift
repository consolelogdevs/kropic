import AppKit

/// Owns `AppState` and starts it once AppKit has finished launching,
/// which is the earliest point where opening windows is reliable.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(PreviewRenderer.argument) {
            NSApp.activate()
            print("Rendered previews to \(PreviewRenderer.renderAll().path)")
            exit(0)
        }
        #endif
        appState.start()
    }
}
