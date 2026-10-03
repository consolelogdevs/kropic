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

    init(image: CGImage, scale: CGFloat) {
        self.image = image
        self.scale = scale
        state = .recognizing
        translation = TranslationViewModel(translator: translationProvider)
    }

    init(captureFailure message: String) {
        image = nil
        scale = 1
        state = .failed(message)
        translation = TranslationViewModel(translator: translationProvider)
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
            translation.textChanged(result.text, debounce: false)
        }
    }

    func showFailure(_ message: String) {
        state = .failed(message)
    }

}
