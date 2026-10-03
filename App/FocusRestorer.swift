import AppKit

/// Remembers which app was frontmost before Kropic took focus, and hands focus back to it.
@MainActor
final class FocusRestorer {
    private var previousApp: NSRunningApplication?

    /// Remembers the current frontmost app (unless it is Kropic) and activates Kropic.
    func activateKropic() {
        let frontmost = NSWorkspace.shared.frontmostApplication
        if frontmost?.processIdentifier != ProcessInfo.processInfo.processIdentifier {
            previousApp = frontmost
        }
        NSApp.activate()
    }

    func restore() {
        previousApp?.activate()
        previousApp = nil
    }
}
