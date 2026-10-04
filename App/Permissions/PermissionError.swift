import Foundation

enum PermissionError: LocalizedError {
    case relaunchFailed

    var errorDescription: String? {
        switch self {
        case .relaunchFailed:
            String(localized: "Kropic could not restart itself. Please quit it from the menu bar and open it again.")
        }
    }
}
