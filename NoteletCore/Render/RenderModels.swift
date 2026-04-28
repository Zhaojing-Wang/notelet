import CoreGraphics
import Foundation

public struct RenderRequest: Equatable, Hashable {
    public var document: NoteDocument
    public var template: TemplatePreset
    public var fontPreset: FontPreset
    public var exportPreset: ExportPreset
    public var includesWatermark: Bool

    public init(
        document: NoteDocument,
        template: TemplatePreset = TemplateStore.defaultTemplate,
        fontPreset: FontPreset = FontPresetStore.defaultPreset,
        exportPreset: ExportPreset = .defaultSocial,
        includesWatermark: Bool = true
    ) {
        self.document = document
        self.template = template
        self.fontPreset = fontPreset
        self.exportPreset = exportPreset
        self.includesWatermark = includesWatermark
    }
}

public struct RenderedPage: Identifiable, Equatable {
    public let id: UUID
    public var document: NoteDocument
    public var size: CGSize

    public init(id: UUID = UUID(), document: NoteDocument, size: CGSize) {
        self.id = id
        self.document = document
        self.size = size
    }
}

public enum RenderPlanner {
    public static func pages(for request: RenderRequest) -> [RenderedPage] {
        let engine = PaginationEngine()
        let pageDocuments = engine.paginate(
            request.document,
            template: request.template,
            preset: request.exportPreset
        )

        if request.exportPreset.mode == .longImage || request.exportPreset.ratio == .adaptiveLong {
            let contentHeight = engine.estimatedContentHeight(
                for: request.document,
                template: request.template
            )
            let size = request.exportPreset.ratio.size(
                width: request.exportPreset.width,
                contentHeight: contentHeight
            )
            return [RenderedPage(document: request.document, size: size)]
        }

        let size = request.exportPreset.ratio.size(width: request.exportPreset.width)
        return pageDocuments.map { RenderedPage(document: $0, size: size) }
    }
}

