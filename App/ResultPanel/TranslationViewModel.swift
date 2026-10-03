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
        case idle
        case sameLanguage
        case translating
        case translated(String)
        case needsDownload
        case unsupported
        case failed(String)
    }

    static let editDebounce: Duration = .milliseconds(600)

    private(set) var languages: [Locale.Language] = []
    private(set) var detectedLanguage: Locale.Language?
    private(set) var state: State = .idle

    var sourceSelection: SourceSelection = .automatic {
        didSet { if sourceSelection != oldValue { schedule() } }
    }

    var target: Locale.Language? {
        didSet {
            guard target != oldValue, let target else { return }
            LanguageCatalog.rememberTarget(target)
            schedule()
        }
    }

    @ObservationIgnored private let translator: any Translating
    @ObservationIgnored private let detector = LanguageDetector()
    @ObservationIgnored private var text = ""
    @ObservationIgnored private var work: Task<Void, Never>?

    init(translator: any Translating) {
        self.translator = translator
    }

    var source: Locale.Language? {
        switch sourceSelection {
        case .automatic: detectedLanguage
        case .language(let language): language
        }
    }

    func loadLanguages() async {
        languages = LanguageCatalog.sortedByName(await translator.supportedLanguages)
        if !text.isEmpty {
            // OCR finished first; detect again now that there is a list to match against.
            detectedLanguage = detector.detect(text).flatMap { LanguageCatalog.match($0.language, in: languages) }
        }
        if target == nil {
            target = LanguageCatalog.defaultTarget(in: languages)
        } else {
            schedule()
        }
    }

    /// New text from OCR (`debounce: false`) or from editing (`debounce: true`).
    func textChanged(_ text: String, debounce: Bool) {
        self.text = text
        detectedLanguage = detector.detect(text).flatMap { LanguageCatalog.match($0.language, in: languages) }
        schedule(after: debounce ? Self.editDebounce : .zero)
    }

    func retry() {
        schedule()
    }

    func cancel() {
        work?.cancel()
        work = nil
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
        if availability == .unsupported {
            state = .unsupported
            return
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
            case .languagePackMissing: state = .needsDownload
            case .unidentifiedLanguage, .failed: state = .failed(error.localizedDescription)
            }
        }
    }
}
