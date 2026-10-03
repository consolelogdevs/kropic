import Testing
@testable import KropicCore

struct TextRecognizerTests {
    let recognizer = TextRecognizer()

    @Test func turkishKeepsDiacritics() async throws {
        let text = "Çalışkan öğrenciler şehirdeki büyük kütüphanede ders çalışıyor.\nIşık, ılık süt ve üzüm İstanbul için güzel bir gün."
        let result = try await recognizer.recognize(TestImage.render(text))
        #expect(result.text == text)
    }

    @Test func english() async throws {
        let text = "The quick brown fox jumps over the lazy dog.\nScreen text recognition should keep line breaks."
        let result = try await recognizer.recognize(TestImage.render(text))
        #expect(result.text == text)
    }

    @Test func keepsParagraphs() async throws {
        let text = "First paragraph, first line.\nFirst paragraph, second line.\n\nSecond paragraph starts here."
        let result = try await recognizer.recognize(TestImage.render(text))
        #expect(result.text == text)
    }

    @Test func lightTextOnDarkBackground() async throws {
        let text = "Dark mode text is recognized too."
        let result = try await recognizer.recognize(TestImage.render(text, dark: true))
        #expect(result.text == text)
    }

    @Test func smallInterfaceText() async throws {
        let text = "Settings  General  Appearance  Notifications"
        let result = try await recognizer.recognize(TestImage.render(text, fontSize: 13))
        // Wide spaces between words may come back as single spaces.
        #expect(result.text.split(separator: " ") == text.split(separator: " "))
    }

    @Test func blankImageHasNoText() async throws {
        let result = try await recognizer.recognize(TestImage.render(" "))
        #expect(result.isEmpty)
    }
}
