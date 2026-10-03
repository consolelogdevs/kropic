import SwiftUI

/// Copies `text` to the clipboard and shows "Copied" for a moment.
struct CopyButton: View {
    let text: String

    @State private var didCopy = false
    @State private var resetTask: Task<Void, Never>?

    var body: some View {
        Button(didCopy ? "Copied" : "Copy", systemImage: didCopy ? "checkmark" : "doc.on.doc") {
            Clipboard.copy(text)
            didCopy = true
            resetTask?.cancel()
            resetTask = Task {
                try? await Task.sleep(for: .seconds(1.5))
                guard !Task.isCancelled else { return }
                didCopy = false
            }
        }
        .disabled(text.isEmpty)
    }
}
