import Foundation

/// A translation provider. Apple's on-device translation today, cloud providers later.
///
/// Main-actor isolated because Apple's `TranslationSession` only exists inside a SwiftUI view.
/// A cloud provider can still do its network work off the main actor inside `translate`.
@MainActor
public protocol Translating: AnyObject {
    var supportedLanguages: [Locale.Language] { get async }

    /// Whether `source` → `target` can be translated. With a `nil` source, the provider
    /// identifies the language from `text`.
    func availability(from source: Locale.Language?, to target: Locale.Language, text: String) async -> LanguagePairAvailability

    func translate(_ request: TranslationRequest) async throws(TranslationFailure) -> TranslationResult
}
