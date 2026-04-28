import Foundation
import Testing
@testable import notelet

struct NoteParserTests {
    @Test func parsesTitleParagraphListsQuoteAndDivider() throws {
        let input = """
        会议复盘

        今天主要讨论产品方向。
        第二行仍然属于同一段。

        - 保持 Apple Notes 分享优先
        - 图片导出要足够快

        1. 先做 4:5 多图
        2. 再补长图

        > 从 Apple Notes 分享进来，10 秒内生成漂亮图片。

        ---

        https://example.com
        """

        let document = NoteParser().parse(input)

        #expect(document.title == "会议复盘")
        #expect(document.blocks == [
            .paragraph("今天主要讨论产品方向。\n第二行仍然属于同一段。"),
            .bulletList(["保持 Apple Notes 分享优先", "图片导出要足够快"]),
            .numberedList(["先做 4:5 多图", "再补长图"]),
            .quote("从 Apple Notes 分享进来，10 秒内生成漂亮图片。"),
            .divider,
            .paragraph("https://example.com")
        ])
    }

    @Test func keepsEmptyInputAsEmptyDocument() throws {
        let document = NoteParser().parse(" \n \n")

        #expect(document.title == nil)
        #expect(document.blocks.isEmpty)
    }

    @Test func parsesMarkdownHeadingsWithoutForcingTitle() throws {
        let document = NoteParser().parse("""
        # 产品原则

        ## 图片分享
        只做 Apple Notes 图片化分享。
        """, identifiesFirstLineAsTitle: false)

        #expect(document.title == nil)
        #expect(document.blocks == [
            .heading("产品原则", level: 1),
            .heading("图片分享", level: 2),
            .paragraph("只做 Apple Notes 图片化分享。")
        ])
    }
}
