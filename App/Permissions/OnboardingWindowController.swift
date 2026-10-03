import AppKit
import SwiftUI

/// Shows the onboarding window from anywhere, including the hotkey path where no SwiftUI view exists.
@MainActor
final class OnboardingWindowController {
    private let permissions: PermissionService
    private var window: NSWindow?

    init(permissions: PermissionService) {
        self.permissions = permissions
    }

    func show() {
        let window = window ?? makeWindow()
        self.window = window
        // A menu bar only app is never frontmost on its own, so bring it forward first.
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(contentViewController: NSHostingController(rootView: OnboardingView(permissions: permissions)))
        window.title = "Welcome to Kropic"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }
}
