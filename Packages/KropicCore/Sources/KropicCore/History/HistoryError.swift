import Foundation

public enum HistoryError: LocalizedError, Equatable {
    case saveFailed

    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            "History could not be saved."
        }
    }
}
