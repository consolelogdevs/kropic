import Foundation

public struct TranslationRequest: Sendable, Equatable {
    public var text: String
    /// `nil` lets the provider identify the source language itself.
    public var source: Locale.Language?
    public var target: Locale.Language

    public init(text: String, source: Locale.Language?, target: Locale.Language) {
        self.text = text
        self.source = source
        self.target = target
    }
}

public struct TranslationResult: Sendable, Equatable {
    public var text: String
    public var source: Locale.Language
    public var target: Locale.Language

    public init(text: String, source: Locale.Language, target: Locale.Language) {
        self.text = text
        self.source = source
        self.target = target
    }
}

public enum LanguagePairAvailability: Sendable, Equatable {
    /// Ready to translate offline.
    case installed
    /// Supported, but a language pack has to be downloaded first.
    case downloadable
    case unsupported
}

public enum TranslationFailure: LocalizedError, Equatable {
    case cancelled
    case unsupportedPair
    case languagePackMissing
    case unidentifiedLanguage
    case failed

    public var errorDescription: String? {
        switch self {
        case .cancelled:
            "Translation was cancelled."
        case .unsupportedPair:
            "Translation between these languages isn't supported."
        case .languagePackMissing:
            "The language pack for this translation isn't downloaded yet."
        case .unidentifiedLanguage:
            "The language of this text couldn't be identified. Pick the source language."
        case .failed:
            "The text couldn't be translated. Please try again."
        }
    }
}
