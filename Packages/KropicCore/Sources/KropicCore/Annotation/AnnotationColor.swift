import CoreGraphics

/// The preset colors for annotations, as plain RGB so the core stays UI-framework free.
public enum AnnotationColor: String, CaseIterable, Sendable, Codable {
    case red, yellow, blue, black, white

    public var components: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        switch self {
        case .red: (1.0, 0.23, 0.19)
        case .yellow: (1.0, 0.8, 0.0)
        case .blue: (0.0, 0.38, 0.8)
        case .black: (0.0, 0.0, 0.0)
        case .white: (1.0, 1.0, 1.0)
        }
    }

    public func cgColor(alpha: CGFloat = 1) -> CGColor {
        CGColor(srgbRed: components.red, green: components.green, blue: components.blue, alpha: alpha)
    }
}
