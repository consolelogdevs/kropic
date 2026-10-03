import Foundation
import Testing
@testable import KropicCore

struct HistoryStoreTests {
    let fileURL = FileManager.default.temporaryDirectory
        .appending(path: "KropicTests-\(UUID().uuidString)")
        .appending(path: "History.json")

    private func entry(_ text: String) -> HistoryEntry {
        HistoryEntry(text: text, translation: "translated \(text)", sourceLanguage: "tr", targetLanguage: "en")
    }

    @Test func newestFirst() async throws {
        let store = HistoryStore(fileURL: fileURL)
        try await store.add(entry("one"))
        try await store.add(entry("two"))
        #expect(await store.entries().map(\.text) == ["two", "one"])
    }

    @Test func keepsOnlyTheLimit() async throws {
        let store = HistoryStore(fileURL: fileURL)
        for index in 1...(HistoryStore.limit + 5) {
            try await store.add(entry("\(index)"))
        }
        let texts = await store.entries().map(\.text)
        #expect(texts.count == HistoryStore.limit)
        #expect(texts.first == "\(HistoryStore.limit + 5)")
        #expect(texts.last == "6")
    }

    @Test func persistsAcrossInstances() async throws {
        try await HistoryStore(fileURL: fileURL).add(entry("saved"))
        let reloaded = await HistoryStore(fileURL: fileURL).entries()
        #expect(reloaded.map(\.text) == ["saved"])
        #expect(reloaded.first?.translation == "translated saved")
    }

    @Test func clearEmptiesTheFileToo() async throws {
        let store = HistoryStore(fileURL: fileURL)
        try await store.add(entry("gone"))
        try await store.clear()
        #expect(await store.entries().isEmpty)
        #expect(await HistoryStore(fileURL: fileURL).entries().isEmpty)
    }

    @Test func damagedFileMeansEmptyHistory() async throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: fileURL)
        let store = HistoryStore(fileURL: fileURL)
        #expect(await store.entries().isEmpty)
        try await store.add(entry("fresh"))
        #expect(await store.entries().map(\.text) == ["fresh"])
    }
}
