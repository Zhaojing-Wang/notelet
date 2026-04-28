import CoreGraphics
import Foundation

public struct PaginationEngine {
    public init() {}

    public func paginate(
        _ document: NoteDocument,
        template: TemplatePreset,
        preset: ExportPreset
    ) -> [NoteDocument] {
        guard preset.mode == .autoPages || preset.mode == .manualPages else {
            return [document]
        }

        guard !document.blocks.isEmpty else {
            return [document]
        }

        let pageSize = preset.ratio.size(width: preset.width)
        let verticalPadding = CGFloat(template.padding * 2)
        let maxContentHeight = max(pageSize.height - verticalPadding, pageSize.height * 0.72)
        let firstPageTitleHeight: CGFloat = document.title == nil ? 0 : 86

        var pages: [NoteDocument] = []
        var currentBlocks: [NoteBlock] = []
        var currentHeight = firstPageTitleHeight
        var isFirstPage = true

        func appendPage() {
            guard !currentBlocks.isEmpty || (isFirstPage && document.title != nil) else { return }
            pages.append(NoteDocument(
                title: isFirstPage ? document.title : nil,
                blocks: currentBlocks,
                source: document.source,
                createdAt: document.createdAt
            ))
            currentBlocks.removeAll()
            currentHeight = 0
            isFirstPage = false
        }

        for block in document.blocks {
            let blockHeight = estimatedHeight(for: block, template: template)
            if !currentBlocks.isEmpty, currentHeight + blockHeight > maxContentHeight {
                appendPage()
            }
            currentBlocks.append(block)
            currentHeight += blockHeight
        }

        appendPage()
        return pages.isEmpty ? [document] : pages
    }

    public func estimatedContentHeight(
        for document: NoteDocument,
        template: TemplatePreset
    ) -> CGFloat {
        let titleHeight: CGFloat = document.title == nil ? 0 : 86
        let blocksHeight = document.blocks.reduce(CGFloat(0)) { partial, block in
            partial + estimatedHeight(for: block, template: template)
        }
        return titleHeight + blocksHeight + CGFloat(template.padding * 2)
    }

    private func estimatedHeight(for block: NoteBlock, template: TemplatePreset) -> CGFloat {
        let spacing = CGFloat(template.paragraphSpacing)
        switch block {
        case .heading(let text, let level):
            let base: CGFloat = level == 1 ? 58 : 48
            return base + wrappedLineBonus(for: text, charactersPerLine: 18, lineHeight: 24) + spacing
        case .paragraph(let text):
            return 34 + wrappedLineBonus(for: text, charactersPerLine: 24, lineHeight: 26) + spacing
        case .link(let url):
            return 42 + wrappedLineBonus(for: url, charactersPerLine: 26, lineHeight: 24) + spacing
        case .image(let attachment):
            return imageHeight(for: attachment, template: template) + spacing
        case .bulletList(let items), .numberedList(let items):
            let itemHeights = items.reduce(CGFloat(0)) { partial, item in
                partial + 28 + wrappedLineBonus(for: item, charactersPerLine: 22, lineHeight: 22)
            }
            return itemHeights + spacing
        case .quote(let text):
            return 44 + wrappedLineBonus(for: text, charactersPerLine: 22, lineHeight: 24) + spacing
        case .divider:
            return 38 + spacing
        }
    }

    private func imageHeight(for attachment: NoteImageAttachment, template: TemplatePreset) -> CGFloat {
        let contentWidth = max(1080 - CGFloat(template.padding * 2), 320)
        let naturalHeight = contentWidth / max(attachment.aspectRatio, 0.2)
        return min(max(naturalHeight, 180), 520)
    }

    private func wrappedLineBonus(
        for text: String,
        charactersPerLine: Int,
        lineHeight: CGFloat
    ) -> CGFloat {
        let explicitLines = max(text.split(separator: "\n", omittingEmptySubsequences: false).count, 1)
        let wrappedLines = max(Int(ceil(Double(text.count) / Double(charactersPerLine))), 1)
        let lineCount = max(explicitLines, wrappedLines)
        return CGFloat(max(lineCount - 1, 0)) * lineHeight
    }
}
