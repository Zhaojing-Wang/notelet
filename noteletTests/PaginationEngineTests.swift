import Foundation
import Testing
@testable import notelet

struct PaginationEngineTests {
    @Test func defaultsToAutoPagesFourByFive() throws {
        let preset = ExportPreset.defaultSocial

        #expect(preset.mode == .autoPages)
        #expect(preset.ratio == .portrait4x5)
        #expect(preset.width == 1080)
    }

    @Test func singleCardModeKeepsDocumentTogether() throws {
        let document = NoteDocument(
            title: "短句",
            blocks: [.paragraph("把备忘录变成图片。")],
            source: .manual,
            createdAt: Date(timeIntervalSince1970: 0)
        )

        let pages = PaginationEngine().paginate(
            document,
            template: TemplateStore.builtInTemplates[0],
            preset: ExportPreset(mode: .singleCard, ratio: .portrait4x5)
        )

        #expect(pages.count == 1)
        #expect(pages[0].title == "短句")
        #expect(pages[0].blocks == [.paragraph("把备忘录变成图片。")])
    }

    @Test func autoPagesSplitsLongDocumentsAtBlockBoundaries() throws {
        let blocks = (1...36).map { index in
            NoteBlock.paragraph("第 \(index) 段内容，用来模拟 Apple Notes 里较长的文本。")
        }
        let document = NoteDocument(
            title: "长文",
            blocks: blocks,
            source: .shareExtension,
            createdAt: Date(timeIntervalSince1970: 0)
        )

        let pages = PaginationEngine().paginate(
            document,
            template: TemplateStore.builtInTemplates[0],
            preset: .defaultSocial
        )

        #expect(pages.count > 1)
        #expect(pages[0].title == "长文")
        #expect(pages.dropFirst().allSatisfy { $0.title == nil })
        #expect(pages.flatMap(\.blocks) == blocks)
    }
}
