import Testing
@testable import KropicCore

struct LanguageDetectorTests {
    let detector = LanguageDetector()

    @Test(arguments: [
        ("Bugün hava çok güzel, parkta yürüyüş yapmaya gidiyoruz.", "tr"),
        ("The weather is lovely today, we are going for a walk in the park.", "en"),
        ("Das Wetter ist heute sehr schön, wir gehen im Park spazieren.", "de"),
    ])
    func detectsSentences(text: String, expected: String) {
        #expect(detector.detect(text)?.language.languageCode?.identifier == expected)
    }

    @Test func emptyAndTinyTextGiveNil() {
        #expect(detector.detect("") == nil)
        #expect(detector.detect("  42 ") == nil)
        #expect(detector.detect("ok") == nil)
    }

    @Test func mixedTextGivesDominantLanguage() {
        let text = "Toplantı yarın saat onda başlıyor ve herkesin hazırlıklı gelmesi gerekiyor. See you."
        #expect(detector.detect(text)?.language.languageCode?.identifier == "tr")
    }
}
