import CoreGraphics
import Foundation

/// One mark on a captured image. Coordinates are image pixels, origin top-left, y downward.
public struct Annotation: Identifiable, Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        case arrow(from: CGPoint, to: CGPoint)
        /// A freehand stroke through these points.
        case pen([CGPoint])
        case rectangle(CGRect)
        /// `origin` is the top-left corner of the text.
        case text(String, origin: CGPoint, fontSize: CGFloat)
        case highlight(CGRect)
        case blur(CGRect)
        case pixelate(CGRect)
    }

    public var id: UUID
    public var kind: Kind
    public var color: AnnotationColor
    /// Stroke width in pixels for arrows and rectangles.
    public var lineWidth: CGFloat

    public init(id: UUID = UUID(), kind: Kind, color: AnnotationColor = .red, lineWidth: CGFloat = 6) {
        self.id = id
        self.kind = kind
        self.color = color
        self.lineWidth = lineWidth
    }

    /// Whether the mark hides what is under it (blur or pixelate).
    public var isRedaction: Bool {
        switch kind {
        case .blur, .pixelate: true
        default: false
        }
    }
}
