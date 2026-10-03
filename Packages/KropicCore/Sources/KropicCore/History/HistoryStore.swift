import Foundation

/// The most recent results, newest first, kept in a JSON file.
public actor HistoryStore {
    public static let limit = 20

    private let fileURL: URL
    private var cache: [HistoryEntry]?

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// `History.json` in Application Support. Inside the app sandbox this is the app's own container.
    public static func defaultFileURL() -> URL {
        URL.applicationSupportDirectory.appending(path: "History.json")
    }

    public func entries() -> [HistoryEntry] {
        if let cache {
            return cache
        }
        let loaded = load()
        cache = loaded
        return loaded
    }

    public func add(_ entry: HistoryEntry) throws(HistoryError) {
        let updated = Array(([entry] + entries()).prefix(Self.limit))
        try save(updated)
        cache = updated
    }

    public func clear() throws(HistoryError) {
        try save([])
        cache = []
    }

    /// A missing or damaged file means an empty history, never a crash.
    private func load() -> [HistoryEntry] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? Self.decoder.decode([HistoryEntry].self, from: data)) ?? []
    }

    private func save(_ entries: [HistoryEntry]) throws(HistoryError) {
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Self.encoder.encode(entries).write(to: fileURL, options: .atomic)
        } catch {
            throw .saveFailed
        }
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
