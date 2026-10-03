import Foundation

/// Language names, matching and the remembered target language.
enum LanguageCatalog {
    private static let lastTargetKey = "lastTargetLanguage"

    static func displayName(_ language: Locale.Language) -> String {
        Locale.current.localizedString(forIdentifier: language.minimalIdentifier) ?? language.minimalIdentifier
    }

    static func sortedByName(_ languages: [Locale.Language]) -> [Locale.Language] {
        languages.sorted { displayName($0).localizedStandardCompare(displayName($1)) == .orderedAscending }
    }

    /// The entry in `supported` that best matches `language`: the same identifier, else the plain
    /// language without a region (e.g. `en` for `en-TR`), else any variant of the same language.
    static func match(_ language: Locale.Language, in supported: [Locale.Language]) -> Locale.Language? {
        if let exact = supported.first(where: { $0.minimalIdentifier == language.minimalIdentifier }) {
            return exact
        }
        let sameLanguage = supported.filter { $0.languageCode == language.languageCode }
        return sameLanguage.first { $0.region == nil } ?? sameLanguage.first
    }

    /// True when translating between the two would be pointless, e.g. `en` and `en-GB`.
    /// Different scripts of one language (Simplified and Traditional Chinese) count as different.
    static func isSameLanguage(_ a: Locale.Language, _ b: Locale.Language) -> Bool {
        let scriptA = Locale.Language(identifier: a.maximalIdentifier).script
        let scriptB = Locale.Language(identifier: b.maximalIdentifier).script
        return a.languageCode == b.languageCode && scriptA == scriptB
    }

    /// Last used target, else the system language, else English.
    static func defaultTarget(in supported: [Locale.Language]) -> Locale.Language? {
        if let stored = UserDefaults.standard.string(forKey: lastTargetKey),
           let match = match(Locale.Language(identifier: stored), in: supported) {
            return match
        }
        return match(Locale.current.language, in: supported)
            ?? match(Locale.Language(identifier: "en"), in: supported)
            ?? supported.first
    }

    static func rememberTarget(_ language: Locale.Language) {
        UserDefaults.standard.set(language.minimalIdentifier, forKey: lastTargetKey)
    }
}
