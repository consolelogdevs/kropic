import Foundation

enum ImageSaveError: LocalizedError {
    case writeFailed

    var errorDescription: String? {
        switch self {
        case .writeFailed:
            String(localized: "The image could not be saved. Please choose another location and try again.")
        }
    }
}
