import Foundation

/// One past result. Text only: images are never stored (D-005).
public struct HistoryEntry: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var date: Date
    public var text: String
    public var translation: String?
    /// Language identifiers such as `tr` or `en-GB`.
    public var sourceLanguage: String?
    public var targetLanguage: String?

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        text: String,
        translation: String?,
        sourceLanguage: String?,
        targetLanguage: String?
    ) {
        self.id = id
        self.date = date
        self.text = text
        self.translation = translation
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
    }
}
