import Foundation

public struct SharedDraft: Codable, Equatable, Identifiable, Hashable {
    public let id: UUID
    public var document: NoteDocument
    public var createdAt: Date

    public init(id: UUID = UUID(), document: NoteDocument, createdAt: Date = Date()) {
        self.id = id
        self.document = document
        self.createdAt = createdAt
    }
}

public enum SharedDraftStore {
    private static var fileURL: URL {
        AppGroupStorage.containerURL.appendingPathComponent("latest-draft.json")
    }

    public static func save(_ draft: SharedDraft) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(draft)
        try data.write(to: fileURL, options: [.atomic])
    }

    public static func loadLatest() -> SharedDraft? {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(SharedDraft.self, from: data)
        } catch {
            return nil
        }
    }
}

