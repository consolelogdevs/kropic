import Foundation

public enum OCRError: LocalizedError, Equatable {
    case cancelled
    case failed

    public var errorDescription: String? {
        switch self {
        case .cancelled:
            "Text recognition was cancelled."
        case .failed:
            "Text could not be recognized in this image. Please try again."
        }
    }
}
