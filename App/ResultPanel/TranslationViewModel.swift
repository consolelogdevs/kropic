import Foundation
import KropicCore
import Observation

@MainActor
@Observable
final class TranslationViewModel {
    enum SourceSelection: Hashable {
        case automatic
        case language(Locale.Language)
    }

    enum State: Equatable {
        /// No text yet, or nothing to translate.
        case idle
        /// Automatic translation is off; waiting for the Translate button.
        case ready
        case sameLanguage
        case translating
        case translated(String)
        /// The pair is downloadable but not installed; the notice asks first (D-037).
        case needsDownload
        /// The user chose "Not Now" on the download notice.
        case downloadDeclined
        case unsupported
        case failed(String)
    }

    static let editDebounce: Duration = .milliseconds(600)

    private(set) var languages: [Locale.Language] = []
    private(set) var detectedLanguage: Locale.Language?
    private(set) var state: State = .idle

    var sourceSelection: SourceSelection = .automatic {
        didSet { if sourceSelection != oldValue { requestTranslation() } }
    }

    var target: Locale.Language? {
        didSet {
            guard target != oldValue, let target else { return }
            settings.lastTargetLanguage = target.minimalIdentifier
            requestTranslation()
        }
    }

    @ObservationIgnored private let translator: any Translating
    @ObservationIgnored private let settings: AppSettings
    @ObservationIgnored private let detector = LanguageDetector()
    @ObservationIgnored private var text = ""
    @ObservationIgnored private var work: Task<Void, Never>?
    /// Pairs the user agreed to download in this panel, as "source>target".
    @ObservationIgnored private var approvedDownloads: Set<String> = []
    @ObservationIgnored private var suspendsRequests = false

    init(translator: any Translating, settings: AppSettings) {
        self.translator = translator
        self.settings = settings
    }

    var source: Locale.Language? {
        switch sourceSelection {
        case .automatic: detectedLanguage
        case .language(let language): language
        }
    }

    var translatedText: String? {
        if case .translated(let text) = state { text } else { nil }
    }

    /// "English · detected" for the chip next to the extracted text label.
    var detectedChipText: String? {
        guard sourceSelection == .automatic, let detectedLanguage else { return nil }
        return String(localized: "\(LanguageCatalog.displayName(detectedLanguage)) · detected")
    }

    /// "Japanese → Turkish"
    var pairName: String {
        let sourceName = source.map(LanguageCatalog.displayName) ?? String(localized: "Detected language")
        let targetName = target.map(LanguageCatalog.displayName) ?? ""
        return "\(sourceName) → \(targetName)"
    }

    func loadLanguages() async {
        languages = LanguageCatalog.sortedByName(await translator.supportedLanguages)
        if !text.isEmpty {
            // OCR finished first; detect again now that there is a list to match against.
            detectedLanguage = detector.detect(text).flatMap { LanguageCatalog.match($0.language, in: languages) }
        }
        if target == nil {
            target = LanguageCatalog.defaultTarget(in: languages, preferred: settings.preferredTargetLanguage)
        } else {
            requestTranslation()
        }
    }

    /// New text from OCR (`debounce: false`) or from editing (`debounce: true`).
    func textChanged(_ text: String, debounce: Bool) {
        self.text = text
        detectedLanguage = detector.detect(text).flatMap { LanguageCatalog.match($0.language, in: languages) }
        requestTranslation(after: debounce ? Self.editDebounce : .zero)
    }

    /// The Translate and Try Again buttons.
    func translateNow() {
        schedule()
    }

    /// "Download" on the language pack notice: translating the pair makes macOS show its prompt.
    func downloadLanguagePack() {
        if let key = pairKey {
            approvedDownloads.insert(key)
        }
        schedule()
    }

    /// "Not Now" on the language pack notice.
    func declineDownload() {
        cancel()
        state = .downloadDeclined
    }

    func swapLanguages(newText: String) {
        guard let oldSource = source, let oldTarget = target else { return }
        suspendsRequests = true
        sourceSelection = .language(oldTarget)
        target = oldSource
        suspendsRequests = false
        text = newText
        schedule()
    }

    func cancel() {
        work?.cancel()
        work = nil
    }

    private var pairKey: String? {
        guard let target else { return nil }
        return "\(source?.minimalIdentifier ?? "auto")>\(target.minimalIdentifier)"
    }

    /// Translates now or after `delay` when automatic translation is on, otherwise waits for the button.
    private func requestTranslation(after delay: Duration = .zero) {
        guard !suspendsRequests else { return }
        if settings.translateAutomatically {
            schedule(after: delay)
        } else {
            cancel()
            state = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .idle : .ready
        }
    }

    private func schedule(after delay: Duration = .zero) {
        work?.cancel()
        work = Task { [weak self] in
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            guard !Task.isCancelled else { return }
            await self?.translate()
        }
    }

    private func translate() async {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let target else {
            state = .idle
            return
        }
        let source = source
        if let source, LanguageCatalog.isSameLanguage(source, target) {
            state = .sameLanguage
            return
        }

        state = .translating
        let availability = await translator.availability(from: source, to: target, text: text)
        guard !Task.isCancelled else { return }
        switch availability {
        case .unsupported:
            state = .unsupported
            return
        case .downloadable where !approvedDownloads.contains(pairKey ?? ""):
            state = .needsDownload
            return
        case .installed, .downloadable:
            break
        }

        do throws(TranslationFailure) {
            let result = try await translator.translate(TranslationRequest(text: text, source: source, target: target))
            guard !Task.isCancelled else { return }
            if source == nil {
                detectedLanguage = LanguageCatalog.match(result.source, in: languages)
            }
            state = .translated(result.text)
        } catch {
            guard !Task.isCancelled else { return }
            switch error {
            case .cancelled: break
            case .unsupportedPair: state = .unsupported
            case .languagePackMissing:
                // The user declined Apple's prompt; ask again next time.
                if let key = pairKey { approvedDownloads.remove(key) }
                state = .needsDownload
            case .unidentifiedLanguage, .failed: state = .failed(error.localizedDescription)
            }
        }
    }

    #if DEBUG
    func setPreview(languages: [Locale.Language], detected: Locale.Language?, target: Locale.Language?, state: State) {
        suspendsRequests = true
        self.languages = languages
        detectedLanguage = detected
        self.target = target
        self.state = state
    }
    #endif
}
