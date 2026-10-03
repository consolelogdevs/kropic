import CoreGraphics
import KropicCore
import Observation

@MainActor
@Observable
final class ResultViewModel {
    enum Content {
        case image(CGImage, scale: CGFloat)
        case failure(String)
    }

    static let maxImageSide: CGFloat = 360

    let content: Content

    init(content: Content) {
        self.content = content
    }

    /// The image's size in points, scaled down to fit the panel.
    var imageDisplaySize: CGSize {
        guard case .image(let image, let scale) = content else { return .zero }
        let points = CGSize(width: CGFloat(image.width) / scale, height: CGFloat(image.height) / scale)
        return Placement.fitted(points, maxSide: Self.maxImageSide)
    }
}
