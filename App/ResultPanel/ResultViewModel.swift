import AppKit
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
    var text = ""
    private(set) var didCopy = false

    @ObservationIgnored private var copyResetTask: Task<Void, Never>?

    init(image: CGImage, scale: CGFloat) {
        self.image = image
        self.scale = scale
        state = .recognizing
    }

    init(captureFailure message: String) {
        image = nil
        scale = 1
        state = .failed(message)
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
        }
    }

    func showFailure(_ message: String) {
        state = .failed(message)
    }

    func copyText() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        didCopy = true
        copyResetTask?.cancel()
        copyResetTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            self?.didCopy = false
        }
    }
}
