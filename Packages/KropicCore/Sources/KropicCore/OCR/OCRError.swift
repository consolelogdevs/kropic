import Foundation

public enum OCRError: LocalizedError, Equatable {
    case cancelled
    case failed

    public var errorDescription: String? {
        switch self {
        case .cancelled:
            String(localized: "Text recognition was cancelled.", bundle: .module)
        case .failed:
            String(localized: "Text could not be recognized in this image. Please try again.", bundle: .module)
        }
    }
}
