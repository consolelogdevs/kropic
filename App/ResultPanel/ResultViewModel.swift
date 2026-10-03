import CoreGraphics
import KropicCore
import Observation

@MainActor
@Observable
final class ResultViewModel {
    enum State: Equatable {
        case recognizing
        case recognized
        case noText
        case failed(String)
    }

    static let maxImageSide: CGFloat = 360

    /// `nil` when the capture itself failed.
    let image: CGImage?
    let scale: CGFloat
    private(set) var state: State
    var text = "" {
        didSet {
            if text != oldValue, state == .recognized {
                translation.textChanged(text, debounce: true)
            }
        }
    }

    let translationProvider = AppleTranslationProvider()
    let translation: TranslationViewModel
    @ObservationIgnored private let settings: AppSettings

    init(image: CGImage, scale: CGFloat, settings: AppSettings) {
        self.image = image
        self.scale = scale
        self.settings = settings
        state = .recognizing
        translation = TranslationViewModel(translator: translationProvider, settings: settings)
    }

    init(captureFailure message: String, settings: AppSettings) {
        image = nil
        scale = 1
        self.settings = settings
        state = .failed(message)
        translation = TranslationViewModel(translator: translationProvider, settings: settings)
    }

    /// What to keep in history: the text as the user left it, and the translation if there is one.
    var historyEntry: HistoryEntry? {
        guard state == .recognized, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        var translated: String?
        if case .translated(let value) = translation.state {
            translated = value
        }
        return HistoryEntry(
            text: text,
            translation: translated,
            sourceLanguage: translation.source?.minimalIdentifier,
            targetLanguage: translated == nil ? nil : translation.target?.minimalIdentifier
        )
    }

    /// The image's size in points, scaled down to fit the panel.
    var imageDisplaySize: CGSize {
        guard let image else { return .zero }
        let points = CGSize(width: CGFloat(image.width) / scale, height: CGFloat(image.height) / scale)
        return Placement.fitted(points, maxSide: Self.maxImageSide)
    }

    func show(_ result: RecognizedText) {
        if result.isEmpty {
            state = .noText
        } else {
            text = result.text
            state = .recognized
            if settings.copyTextAutomatically {
                Clipboard.copy(result.text)
            }
            translation.textChanged(result.text, debounce: false)
        }
    }

    func showFailure(_ message: String) {
        state = .failed(message)
    }

}
