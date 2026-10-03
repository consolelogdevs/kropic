import KropicCore
import SwiftUI
import Translation

/// Attaches Apple's `.translationTask` to a view so `AppleTranslationProvider` gets sessions.
/// The system also uses this view's window to show the language pack download prompt.
struct TranslationHost: ViewModifier {
    let provider: AppleTranslationProvider

    func body(content: Content) -> some View {
        // `@Sendable` keeps the closure off the main actor: `TranslationSession` is not Sendable,
        // so it has to be used where it was handed to us instead of crossing to the main actor.
        content.translationTask(provider.configuration) { @Sendable session in
            await Self.translateQueuedRequest(with: session, for: provider)
        }
    }

    private nonisolated static func translateQueuedRequest(with session: TranslationSession, for provider: AppleTranslationProvider) async {
        guard let (id, request) = await provider.takeQueuedRequest() else { return }
        let outcome: Result<TranslationResult, any Error>
        do {
            let response = try await session.translate(request.text)
            outcome = .success(TranslationResult(
                text: response.targetText,
                source: response.sourceLanguage,
                target: response.targetLanguage
            ))
        } catch {
            outcome = .failure(error)
        }
        await provider.finish(id, request: request, outcome: outcome)
    }
}
