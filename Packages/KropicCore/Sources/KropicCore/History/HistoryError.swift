import Foundation

public enum HistoryError: LocalizedError, Equatable {
    case saveFailed

    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            String(localized: "History could not be saved.", bundle: .module)
        }
    }
}
