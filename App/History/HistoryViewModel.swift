import KropicCore
import Observation

@MainActor
@Observable
final class HistoryViewModel {
    private(set) var entries: [HistoryEntry] = []
    private(set) var copiedEntryID: HistoryEntry.ID?
    private(set) var errorMessage: String?

    @ObservationIgnored private let store: HistoryStore
    @ObservationIgnored private var copyResetTask: Task<Void, Never>?

    init(store: HistoryStore) {
        self.store = store
    }

    func reload() async {
        entries = await store.entries()
    }

    func add(_ entry: HistoryEntry) async {
        do {
            try await store.add(entry)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        await reload()
    }

    func clear() async throws(HistoryError) {
        try await store.clear()
        await reload()
    }

    func copy(_ text: String, from entry: HistoryEntry) {
        Clipboard.copy(text)
        copiedEntryID = entry.id
        copyResetTask?.cancel()
        copyResetTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            self?.copiedEntryID = nil
        }
    }
}
