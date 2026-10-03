import CoreGraphics

/// One piece of text Vision found, usually a full line.
public struct RecognizedLine: Sendable, Equatable {
    public var text: String
    public var confidence: Float
    /// Position in the image, normalized to 0...1, origin top-left, y grows downward.
    public var bounds: CGRect

    public init(text: String, confidence: Float, bounds: CGRect) {
        self.text = text
        self.confidence = confidence
        self.bounds = bounds
    }
}
