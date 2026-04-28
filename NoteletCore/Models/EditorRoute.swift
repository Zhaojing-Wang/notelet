import Foundation

public struct EditorRoute: Hashable {
    public var document: NoteDocument
    public var templateID: String
    public var fontPresetID: String
    public var exportPreset: ExportPreset

    public init(
        document: NoteDocument,
        templateID: String = TemplateStore.defaultTemplate.id,
        fontPresetID: String = FontPresetStore.defaultPreset.id,
        exportPreset: ExportPreset = .defaultSocial
    ) {
        self.document = document
        self.templateID = templateID
        self.fontPresetID = fontPresetID
        self.exportPreset = exportPreset
    }

    public init(record: HistoryRecord) {
        self.document = record.document
        self.templateID = record.templateID
        self.fontPresetID = record.fontPresetID
        self.exportPreset = record.exportPreset
    }
}

