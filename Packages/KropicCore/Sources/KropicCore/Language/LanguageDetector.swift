import Foundation
import NaturalLanguage

/// Finds the dominant language of a text. Short or mixed text can be detected wrongly,
/// so callers should always let the user override the result.
public struct LanguageDetector: Sendable {
    static let minimumLetters = 3
    static let minimumConfidence = 0.5

    public init() {}

    /// `nil` when the text is too short or no language is clearly dominant.
    public func detect(_ text: String) -> DetectedLanguage? {
        let letters = text.unicodeScalars.filter(CharacterSet.letters.contains).count
        guard letters >= Self.minimumLetters else { return nil }

        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        guard let (language, confidence) = recognizer.languageHypotheses(withMaximum: 1).first,
              confidence >= Self.minimumConfidence
        else { return nil }

        return DetectedLanguage(language: Locale.Language(identifier: language.rawValue), confidence: confidence)
    }
}
