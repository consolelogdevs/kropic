import Foundation
import Observation

/// User preferences, backed by UserDefaults. The only place that knows the keys.
@MainActor
@Observable
final class AppSettings {
    private enum Key {
        static let defaultTargetLanguage = "defaultTargetLanguage"
        static let lastTargetLanguage = "lastTargetLanguage"
        static let translateAutomatically = "translateAutomatically"
        static let copyTextAutomatically = "copyTextAutomatically"
        static let saveHistory = "saveHistory"
        static let appearance = "appearance"
        static let overlayUses = "overlayUses"
    }

    @ObservationIgnored private let defaults: UserDefaults

    /// A fixed target language identifier, or `nil` for "Last used".
    var defaultTargetLanguage: String? {
        didSet { defaults.set(defaultTargetLanguage, forKey: Key.defaultTargetLanguage) }
    }

    var lastTargetLanguage: String? {
        didSet { defaults.set(lastTargetLanguage, forKey: Key.lastTargetLanguage) }
    }

    var translateAutomatically: Bool {
        didSet { defaults.set(translateAutomatically, forKey: Key.translateAutomatically) }
    }

    var copyTextAutomatically: Bool {
        didSet { defaults.set(copyTextAutomatically, forKey: Key.copyTextAutomatically) }
    }

    var saveHistory: Bool {
        didSet { defaults.set(saveHistory, forKey: Key.saveHistory) }
    }

    /// How often the selection overlay has been opened, for the first-use hint.
    var overlayUses: Int {
        didSet { defaults.set(overlayUses, forKey: Key.overlayUses) }
    }

    /// Applied immediately to every window through `AppearanceService`.
    var appearance: AppearanceMode {
        didSet {
            defaults.set(appearance.rawValue, forKey: Key.appearance)
            AppearanceService.apply(appearance)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.translateAutomatically: true,
            Key.copyTextAutomatically: false,
            Key.saveHistory: true,
        ])
        defaultTargetLanguage = defaults.string(forKey: Key.defaultTargetLanguage)
        lastTargetLanguage = defaults.string(forKey: Key.lastTargetLanguage)
        translateAutomatically = defaults.bool(forKey: Key.translateAutomatically)
        copyTextAutomatically = defaults.bool(forKey: Key.copyTextAutomatically)
        saveHistory = defaults.bool(forKey: Key.saveHistory)
        overlayUses = defaults.integer(forKey: Key.overlayUses)
        appearance = defaults.string(forKey: Key.appearance).flatMap(AppearanceMode.init(rawValue:)) ?? .system
    }

    /// The target to start a new capture with: the fixed default if set, else the last used one.
    var preferredTargetLanguage: String? {
        defaultTargetLanguage ?? lastTargetLanguage
    }
}
