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

    /// The image fits in the left column, at most this tall.
    static let maxImageHeight: CGFloat = 240

    /// `nil` when the capture itself failed.
    let image: CGImage?
    let scale: CGFloat
    /// The selection in points, shown in the header and under the image.
    let selectionSize: CGSize
    private(set) var state: State
    var text = "" {
        didSet {
            if text != oldValue, state == .recognized, !isApplyingSwap {
                translation.textChanged(text, debounce: true)
            }
        }
    }

    let translationProvider = AppleTranslationProvider()
    let translation: TranslationViewModel
    @ObservationIgnored private let settings: AppSettings
    @ObservationIgnored private var isApplyingSwap = false

    init(image: CGImage, scale: CGFloat, selectionSize: CGSize, settings: AppSettings) {
        self.image = image
        self.scale = scale
        self.selectionSize = selectionSize
        self.settings = settings
        state = .recognizing
        translation = TranslationViewModel(translator: translationProvider, settings: settings)
    }

    init(captureFailure message: String, selectionSize: CGSize, settings: AppSettings) {
        image = nil
        scale = 1
        self.selectionSize = selectionSize
        self.settings = settings
        state = .failed(message)
        translation = TranslationViewModel(translator: translationProvider, settings: settings)
    }

    /// What to keep in history: the text as the user left it, and the translation if there is one.
    var historyEntry: HistoryEntry? {
        guard state == .recognized, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let translated = translation.translatedText
        return HistoryEntry(
            text: text,
            translation: translated,
            sourceLanguage: translation.source?.minimalIdentifier,
            targetLanguage: translated == nil ? nil : translation.target?.minimalIdentifier
        )
    }

    /// "412 × 96"
    var sizeText: String {
        "\(Int(selectionSize.width.rounded())) × \(Int(selectionSize.height.rounded()))"
    }

    /// "412 × 96 pt · Retina 2×"
    var imageCaption: String {
        let scaleText = scale >= 2
            ? String(localized: "Retina \(Int(scale.rounded()))×")
            : String(localized: "Standard \(Int(scale.rounded()))×")
        return String(localized: "\(sizeText) pt · \(scaleText)")
    }

    /// The image's size in points, scaled down to fit the left column.
    var imageDisplaySize: CGSize {
        guard let image else { return .zero }
        let points = CGSize(width: CGFloat(image.width) / scale, height: CGFloat(image.height) / scale)
        let factor = min(1, Metrics.ResultPanel.leftColumnWidth / points.width, Self.maxImageHeight / points.height)
        return CGSize(width: points.width * factor, height: points.height * factor)
    }

    var canSwapLanguages: Bool {
        state == .recognized && translation.source != nil && translation.target != nil
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

    func copyText() {
        guard state == .recognized else { return }
        Clipboard.copy(text)
    }

    func copyTranslation() {
        guard let translated = translation.translatedText else { return }
        Clipboard.copy(translated)
    }

    /// Swaps source and target. A finished translation becomes the new text, so it is
    /// translated back into the original language.
    func swapLanguages() {
        guard canSwapLanguages else { return }
        let newText = translation.translatedText ?? text
        isApplyingSwap = true
        text = newText
        isApplyingSwap = false
        translation.swapLanguages(newText: newText)
    }

    #if DEBUG
    func setPreview(state: State, text: String) {
        self.state = state
        isApplyingSwap = true
        self.text = text
        isApplyingSwap = false
    }
    #endif
}
