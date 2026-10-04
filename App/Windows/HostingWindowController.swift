import AppKit
import SwiftUI

/// A regular window with SwiftUI content that can be opened from anywhere, including the
/// hotkey path where no SwiftUI view exists. Reused on every `show()`.
@MainActor
final class HostingWindowController<Content: View> {
    enum TitleBar {
        /// A normal title bar showing the title.
        case standard
        /// Traffic lights only; the content runs up under them and the title is hidden.
        case transparent
    }

    private let title: String
    private let titleBar: TitleBar
    private let resizable: Bool
    private let makeContent: () -> Content
    private var window: NSWindow?

    init(title: String, titleBar: TitleBar = .standard, resizable: Bool = false, content: @escaping () -> Content) {
        self.title = title
        self.titleBar = titleBar
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

    func close() {
        window?.close()
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(contentViewController: NSHostingController(rootView: makeContent()))
        // The title still names the window for Mission Control and accessibility when hidden.
        window.title = title
        var style: NSWindow.StyleMask = [.titled, .closable]
        if resizable {
            style.insert(.resizable)
        }
        if titleBar == .transparent {
            style.insert(.fullSizeContentView)
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
        }
        window.styleMask = style
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }
}
