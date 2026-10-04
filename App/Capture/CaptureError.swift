import Foundation

enum CaptureError: LocalizedError {
    case permissionDenied
    case displayNotFound
    case failed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            String(localized: "Kropic is not allowed to record the screen. Turn it on in System Settings under Privacy & Security → Screen & System Audio Recording.")
        case .displayNotFound:
            String(localized: "The display you selected on is no longer available. Please try again.")
        case .failed:
            String(localized: "The selected area could not be captured. Please try again.")
        }
    }
}
