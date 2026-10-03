import Foundation

public struct DetectedLanguage: Sendable, Equatable {
    public var language: Locale.Language
    /// 0...1, how sure the recognizer is.
    public var confidence: Double

    public init(language: Locale.Language, confidence: Double) {
        self.language = language
        self.confidence = confidence
    }
}
