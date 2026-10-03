import CoreGraphics
import Testing
@testable import KropicCore

struct TextLayoutTests {
    private func line(_ text: String, x: CGFloat = 0.1, y: CGFloat, width: CGFloat = 0.5, height: CGFloat = 0.05) -> RecognizedLine {
        RecognizedLine(text: text, confidence: 1, bounds: CGRect(x: x, y: y, width: width, height: height))
    }

    @Test func ordersRowsTopToBottom() {
        let lines = [line("second", y: 0.17), line("first", y: 0.1)]
        #expect(TextLayout.text(from: lines) == "first\nsecond")
    }

    @Test func joinsPiecesOnTheSameRowLeftToRight() {
        let lines = [
            line("world", x: 0.5, y: 0.101, width: 0.2),
            line("Hello", x: 0.1, y: 0.1, width: 0.2),
        ]
        #expect(TextLayout.text(from: lines) == "Hello world")
    }

    @Test func largeGapBecomesParagraphBreak() {
        let lines = [
            line("one", y: 0.10),
            line("two", y: 0.17),
            line("three", y: 0.35),
        ]
        #expect(TextLayout.text(from: lines) == "one\ntwo\n\nthree")
    }

    @Test func emptyInputGivesEmptyText() {
        #expect(TextLayout.text(from: []) == "")
        #expect(RecognizedText(lines: []).isEmpty)
    }
}
