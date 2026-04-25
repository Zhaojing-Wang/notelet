import Foundation
import Combine

#if canImport(UIKit)
import UIKit
#endif

public struct HistoryRecord: Codable, Equatable, Identifiable, Hashable {
    public let id: UUID
    public var document: NoteDocument
    public var templateID: String
    public var fontPresetID: String
    public var exportPreset: ExportPreset
    public var thumbnailPath: String?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        document: NoteDocument,
        templateID: String,
        fontPresetID: String,
        exportPreset: ExportPreset,
        thumbnailPath: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.document = document
        self.templateID = templateID
        self.fontPresetID = fontPresetID
        self.exportPreset = exportPreset
        self.thumbnailPath = thumbnailPath
        self.createdAt = createdAt
    }
}

@MainActor
public final class HistoryStore: ObservableObject {
    @Published public private(set) var records: [HistoryRecord]

    private let fileURL: URL

    public init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? AppGroupStorage.containerURL.appendingPathComponent("history.json")
        self.records = Self.load(from: self.fileURL)
    }

    public func add(_ record: HistoryRecord) {
        records.removeAll { $0.id == record.id }
        records.insert(record, at: 0)
        if records.count > 30 {
            records = Array(records.prefix(30))
        }
        save()
    }

    public func delete(_ record: HistoryRecord) {
        records.removeAll { $0.id == record.id }
        save()
    }

    public func template(for record: HistoryRecord) -> TemplatePreset {
        TemplateStore.builtInTemplates.first { $0.id == record.templateID } ?? TemplateStore.defaultTemplate
    }

    public func fontPreset(for record: HistoryRecord) -> FontPreset {
        FontPresetStore.builtInPresets.first { $0.id == record.fontPresetID } ?? FontPresetStore.defaultPreset
    }

    #if canImport(UIKit)
    public func saveThumbnail(_ image: UIImage, id: UUID = UUID()) -> String? {
        guard let data = image.pngData() else { return nil }
        do {
            let directory = try AppGroupStorage.ensureDirectory("HistoryThumbnails")
            let url = directory.appendingPathComponent("\(id.uuidString).png")
            try data.write(to: url, options: [.atomic])
            return url.path
        } catch {
            return nil
        }
    }

    public func thumbnail(for record: HistoryRecord) -> UIImage? {
        guard let thumbnailPath = record.thumbnailPath else { return nil }
        return UIImage(contentsOfFile: thumbnailPath)
    }
    #endif

    private func save() {
        do {
            let data = try JSONEncoder.notelet.encode(records)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            assertionFailure("Failed to save history: \(error)")
        }
    }

    private static func load(from fileURL: URL) -> [HistoryRecord] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder.notelet.decode([HistoryRecord].self, from: data)
        } catch {
            return []
        }
    }
}

private extension JSONEncoder {
    static var notelet: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var notelet: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
