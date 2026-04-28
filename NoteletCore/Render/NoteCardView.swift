import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct NoteCardView: View {
    public let document: NoteDocument
    public let template: TemplatePreset
    public let fontPreset: FontPreset
    public let exportSize: CGSize
    public let includesWatermark: Bool

    public init(
        document: NoteDocument,
        template: TemplatePreset,
        fontPreset: FontPreset,
        exportSize: CGSize,
        includesWatermark: Bool
    ) {
        self.document = document
        self.template = template
        self.fontPreset = fontPreset
        self.exportSize = exportSize
        self.includesWatermark = includesWatermark
    }

    public var body: some View {
        ZStack {
            Color(noteletHex: template.backgroundHex)

            VStack(alignment: .leading, spacing: CGFloat(template.paragraphSpacing)) {
                if let title = document.title, !title.isEmpty {
                    Text(title)
                        .font(titleFont)
                        .fontWeight(weight(from: fontPreset.titleWeight))
                        .foregroundStyle(Color(noteletHex: template.textHex))
                        .fixedSize(horizontal: false, vertical: true)
                }

                ForEach(Array(document.blocks.enumerated()), id: \.offset) { _, block in
                    blockView(block)
                }

                Spacer(minLength: 0)

                if includesWatermark && template.watermarkDefault {
                    Text("留笺 Notelet")
                        .font(.system(size: watermarkSize, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(noteletHex: template.secondaryTextHex).opacity(0.72))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityHidden(true)
                }
            }
            .padding(CGFloat(template.padding))
            .frame(width: exportSize.width, height: exportSize.height, alignment: .topLeading)
            .background(Color(noteletHex: template.surfaceHex))
            .clipShape(RoundedRectangle(cornerRadius: CGFloat(template.cornerRadius), style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: CGFloat(template.cornerRadius), style: .continuous)
                    .stroke(Color(noteletHex: template.textHex).opacity(0.06), lineWidth: 1)
            }
            .padding(cardOuterPadding)
        }
        .frame(width: exportSize.width, height: exportSize.height)
    }

    @ViewBuilder
    private func blockView(_ block: NoteBlock) -> some View {
        switch block {
        case .heading(let text, let level):
            Text(text)
                .font(level == 1 ? titleFont : bodyFont.weight(.semibold))
                .foregroundStyle(Color(noteletHex: template.textHex))
                .fixedSize(horizontal: false, vertical: true)
        case .paragraph(let text):
            Text(text)
                .font(bodyFont)
                .lineSpacing(bodyLineSpacing)
                .foregroundStyle(Color(noteletHex: template.textHex))
                .fixedSize(horizontal: false, vertical: true)
        case .link(let url):
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "link")
                    .font(bodyFont.weight(.semibold))
                    .foregroundStyle(Color(noteletHex: template.accentHex))
                    .padding(.top, 2)
                Text(url)
                    .font(bodyFont)
                    .lineSpacing(bodyLineSpacing)
                    .foregroundStyle(Color(noteletHex: template.accentHex))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)
        case .image(let attachment):
            imageBlock(attachment)
        case .bulletList(let items):
            VStack(alignment: .leading, spacing: bodyLineSpacing) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: 14) {
                        Text("•")
                            .font(bodyFont.weight(.semibold))
                            .foregroundStyle(Color(noteletHex: template.accentHex))
                        Text(item)
                            .font(bodyFont)
                            .foregroundStyle(Color(noteletHex: template.textHex))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        case .numberedList(let items):
            VStack(alignment: .leading, spacing: bodyLineSpacing) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("\(index + 1).")
                            .font(bodyFont.weight(.semibold))
                            .foregroundStyle(Color(noteletHex: template.accentHex))
                            .monospacedDigit()
                        Text(item)
                            .font(bodyFont)
                            .foregroundStyle(Color(noteletHex: template.textHex))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        case .quote(let text):
            Text(text)
                .font(bodyFont)
                .lineSpacing(bodyLineSpacing)
                .foregroundStyle(Color(noteletHex: template.textHex))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 22)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(noteletHex: template.accentHex))
                        .frame(width: 6)
                }
        case .divider:
            Rectangle()
                .fill(Color(noteletHex: template.accentHex).opacity(0.34))
                .frame(height: 2)
                .padding(.vertical, 10)
        }
    }

    @ViewBuilder
    private func imageBlock(_ attachment: NoteImageAttachment) -> some View {
        #if canImport(UIKit)
        if let image = UIImage(data: attachment.data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: imageHeight(for: attachment))
                .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous)
                        .stroke(Color(noteletHex: template.textHex).opacity(0.08), lineWidth: 1)
                }
                .accessibilityLabel("备忘录图片")
        }
        #endif
    }

    private var titleFont: Font {
        .system(
            size: 48 * fontPreset.titleScale,
            weight: weight(from: fontPreset.titleWeight),
            design: design(from: fontPreset.titleRole)
        )
    }

    private var bodyFont: Font {
        .system(
            size: 33 * fontPreset.bodyScale,
            weight: weight(from: fontPreset.bodyWeight),
            design: design(from: fontPreset.bodyRole)
        )
    }

    private var bodyLineSpacing: CGFloat {
        12 * fontPreset.lineSpacing
    }

    private var watermarkSize: CGFloat {
        max(18, exportSize.width * 0.018)
    }

    private var imageCornerRadius: CGFloat {
        min(CGFloat(template.cornerRadius), 22)
    }

    private var cardOuterPadding: CGFloat {
        exportSize.width * 0.055
    }

    private func imageHeight(for attachment: NoteImageAttachment) -> CGFloat {
        let contentWidth = max(exportSize.width - CGFloat(template.padding * 2), 320)
        let naturalHeight = contentWidth / max(attachment.aspectRatio, 0.2)
        return min(max(naturalHeight, exportSize.height * 0.16), exportSize.height * 0.38)
    }

    private func design(from role: FontPreset.FontRole) -> Font.Design {
        switch role {
        case .system:
            .default
        case .rounded:
            .rounded
        case .serif:
            .serif
        case .monospaced:
            .monospaced
        }
    }

    private func weight(from name: String) -> Font.Weight {
        switch name {
        case "bold":
            .bold
        case "semibold":
            .semibold
        case "medium":
            .medium
        default:
            .regular
        }
    }
}
