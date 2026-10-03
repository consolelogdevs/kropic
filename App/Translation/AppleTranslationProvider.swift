import Foundation
import KropicCore
import Observation
import Translation

/// Apple's on-device translation behind the `Translating` protocol.
///
/// On macOS 15 a `TranslationSession` only exists inside a SwiftUI `.translationTask`.
/// `translate(_:)` therefore queues the request and changes `configuration`. SwiftUI then runs
/// the task in `TranslationHost`, which takes the request, translates it with the session and
/// hands the outcome back here, resuming the waiting caller.
@MainActor
@Observable
final class AppleTranslationProvider: Translating {
    private(set) var configuration: TranslationSession.Configuration?

    private typealias Continuation = CheckedContinuation<Result<TranslationResult, TranslationFailure>, Never>
    @ObservationIgnored private var queued: (id: UUID, request: TranslationRequest)?
    @ObservationIgnored private var waiting: [UUID: Continuation] = [:]

    var supportedLanguages: [Locale.Language] {
        get async { await Self.loadSupportedLanguages() }
    }

    func availability(from source: Locale.Language?, to target: Locale.Language, text: String) async -> LanguagePairAvailability {
        await Self.checkAvailability(from: source, to: target, text: text)
    }

    func translate(_ request: TranslationRequest) async throws(TranslationFailure) -> TranslationResult {
        let id = UUID()
        let result = await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: Continuation) in
                // A newer request replaces one that has not started yet.
                if let queued {
                    resolve(queued.id, with: .failure(.cancelled))
                }
                waiting[id] = continuation
                queued = (id, request)
                if var configuration, configuration.source == request.source, configuration.target == request.target {
                    configuration.invalidate()
                    self.configuration = configuration
                } else {
                    configuration = TranslationSession.Configuration(source: request.source, target: request.target)
                }
            }
        } onCancel: {
            Task { @MainActor [weak self] in
                self?.resolve(id, with: .failure(.cancelled))
            }
        }
        return try result.get()
    }

    /// Called by `TranslationHost` when the session is ready.
    func takeQueuedRequest() -> (id: UUID, request: TranslationRequest)? {
        defer { queued = nil }
        return queued
    }

    /// Called by `TranslationHost` with the session's outcome.
    func finish(_ id: UUID, request: TranslationRequest, outcome: Result<TranslationResult, any Error>) async {
        switch outcome {
        case .success(let result):
            resolve(id, with: .success(result))
        case .failure(let error):
            resolve(id, with: .failure(await failure(for: error, request: request)))
        }
    }

    private func resolve(_ id: UUID, with result: Result<TranslationResult, TranslationFailure>) {
        if queued?.id == id {
            queued = nil
        }
        waiting.removeValue(forKey: id)?.resume(returning: result)
    }

    private func failure(for error: any Error, request: TranslationRequest) async -> TranslationFailure {
        if error is CancellationError {
            return .cancelled
        }
        if TranslationError.unsupportedLanguagePairing ~= error
            || TranslationError.unsupportedSourceLanguage ~= error
            || TranslationError.unsupportedTargetLanguage ~= error {
            return .unsupportedPair
        }
        if TranslationError.unableToIdentifyLanguage ~= error {
            return .unidentifiedLanguage
        }
        // Declining the download prompt has no dedicated error; a pair that is still
        // not installed afterwards means the language pack is missing.
        if await availability(from: request.source, to: request.target, text: request.text) == .downloadable {
            return .languagePackMissing
        }
        return .failed
    }

    // `LanguageAvailability` is not Sendable, so it is created and used entirely off the main actor.
    private nonisolated static func loadSupportedLanguages() async -> [Locale.Language] {
        await LanguageAvailability().supportedLanguages
    }

    private nonisolated static func checkAvailability(from source: Locale.Language?, to target: Locale.Language, text: String) async -> LanguagePairAvailability {
        let availability = LanguageAvailability()
        if let source {
            return map(await availability.status(from: source, to: target))
        }
        do {
            return map(try await availability.status(for: text, to: target))
        } catch {
            // The language could not be identified; let the translation itself report that.
            return .downloadable
        }
    }

    private nonisolated static func map(_ status: LanguageAvailability.Status) -> LanguagePairAvailability {
        switch status {
        case .installed: .installed
        case .supported: .downloadable
        case .unsupported: .unsupported
        @unknown default: .unsupported
        }
    }
}
