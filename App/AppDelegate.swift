import AppKit

/// Owns `AppState` and starts it once AppKit has finished launching,
/// which is the earliest point where opening windows is reliable.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        appState.start()
    }
}
