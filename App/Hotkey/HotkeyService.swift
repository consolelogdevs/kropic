import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let captureText = Self("captureText", initial: .init(.two, modifiers: [.command, .shift]))
}

/// Listens for the global capture shortcut for the lifetime of the app.
@MainActor
final class HotkeyService {
    private var listener: Task<Void, Never>?

    func start(onCapture: @escaping @MainActor () -> Void) {
        listener?.cancel()
        listener = Task {
            for await _ in KeyboardShortcuts.events(.keyUp, for: .captureText) {
                onCapture()
            }
        }
    }
}
