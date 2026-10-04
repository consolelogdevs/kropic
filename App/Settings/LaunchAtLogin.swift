import Observation
import ServiceManagement

enum LaunchAtLoginError: LocalizedError {
    case changeFailed

    var errorDescription: String? {
        String(localized: "Launch at login could not be changed. Please try again, or add Kropic in System Settings → General → Login Items.")
    }
}

/// Launch at login through `SMAppService`. The status lives in the system, not in UserDefaults.
@MainActor
@Observable
final class LaunchAtLogin {
    private(set) var status: SMAppService.Status = SMAppService.mainApp.status

    var isEnabled: Bool { status == .enabled || status == .requiresApproval }
    var requiresApproval: Bool { status == .requiresApproval }

    func refresh() {
        status = SMAppService.mainApp.status
    }

    func setEnabled(_ enabled: Bool) throws(LaunchAtLoginError) {
        defer { refresh() }
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            throw .changeFailed
        }
    }

    func openLoginItemsSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
