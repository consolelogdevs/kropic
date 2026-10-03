import AppKit
import SwiftUI

/// A regular window with SwiftUI content that can be opened from anywhere, including the
/// hotkey path where no SwiftUI view exists. Reused on every `show()`.
@MainActor
final class HostingWindowController<Content: View> {
    private let title: String
    private let resizable: Bool
    private let makeContent: () -> Content
    private var window: NSWindow?

    init(title: String, resizable: Bool = false, content: @escaping () -> Content) {
        self.title = title
        self.resizable = resizable
        self.makeContent = content
    }

    func show() {
        let window = window ?? makeWindow()
        self.window = window
        // A menu bar only app is never frontmost on its own, so bring it forward first.
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(contentViewController: NSHostingController(rootView: makeContent()))
        window.title = title
        window.styleMask = resizable ? [.titled, .closable, .resizable] : [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }
}
