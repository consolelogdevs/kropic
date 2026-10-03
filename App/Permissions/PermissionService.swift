import AppKit
import CoreGraphics

/// Screen Recording permission checks and the actions around them.
struct PermissionService: Sendable {
    private static let settingsURL = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
    )

    /// Checks without prompting. macOS often keeps returning `false` until the app restarts.
    var hasScreenRecordingAccess: Bool {
        CGPreflightScreenCaptureAccess()
    }

    /// Adds Kropic to the Screen Recording list in System Settings.
    /// The first call per app also shows the system permission alert.
    @discardableResult
    func requestScreenRecordingAccess() -> Bool {
        CGRequestScreenCaptureAccess()
    }

    @MainActor
    func openScreenRecordingSettings() {
        guard let url = Self.settingsURL else { return }
        NSWorkspace.shared.open(url)
    }

    /// Starts a fresh copy of the app, then quits this one.
    @MainActor
    func relaunch() async throws(PermissionError) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        do {
            _ = try await NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: configuration)
        } catch {
            throw .relaunchFailed
        }
        NSApp.terminate(nil)
    }
}
