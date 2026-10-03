import Foundation

/// The result of recognizing text in one image.
public struct RecognizedText: Sendable, Equatable {
    public var lines: [RecognizedLine]
    /// All lines rebuilt into plain text with line and paragraph breaks.
    public var text: String

    public init(lines: [RecognizedLine]) {
        self.lines = lines
        self.text = TextLayout.text(from: lines)
    }

    public var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
