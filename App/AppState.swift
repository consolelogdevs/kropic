import AppKit
import Observation
import os

/// Top-level coordinator. Every way of starting a capture ends up in `startCapture()`.
@MainActor
@Observable
final class AppState {
    private let permissions = PermissionService()
    private let hotkeys = HotkeyService()
    private let onboarding: OnboardingWindowController
    private let logger = Logger(subsystem: "app.kropic", category: "AppState")

    init() {
        onboarding = OnboardingWindowController(permissions: permissions)
    }

    func start() {
        hotkeys.start { [weak self] in
            self?.startCapture()
        }
        if !permissions.hasScreenRecordingAccess {
            onboarding.show()
        }
    }

    func startCapture() {
        guard permissions.hasScreenRecordingAccess else {
            logger.info("Capture requested without Screen Recording permission")
            onboarding.show()
            return
        }
        logger.info("Capture requested")
        showCapturePlaceholder()
    }

    // TODO(Phase 2): replace with the selection overlay.
    private func showCapturePlaceholder() {
        let alert = NSAlert()
        alert.messageText = "Capture would start here"
        alert.informativeText = "The selection overlay arrives in Phase 2."
        NSApp.activate()
        alert.runModal()
    }
}
