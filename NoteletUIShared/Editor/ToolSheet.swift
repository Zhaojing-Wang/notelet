import SwiftUI

struct BackgroundOption: Identifiable, Hashable {
    let id: String
    let title: String
    let group: String
    let backgroundHex: String
    let surfaceHex: String
    let textHex: String
    let secondaryTextHex: String
    let accentHex: String

    static let options: [BackgroundOption] = [
        BackgroundOption(
            id: "warm-paper",
            title: "暖白纸",
            group: "纸感",
            backgroundHex: "#F4EFE7",
            surfaceHex: "#FFFDF8",
            textHex: "#28241F",
            secondaryTextHex: "#817360",
            accentHex: "#B38B58"
        ),
        BackgroundOption(
            id: "cream",
            title: "米色纸",
            group: "纸感",
            backgroundHex: "#EFE2CF",
            surfaceHex: "#FAF1E1",
            textHex: "#302820",
            secondaryTextHex: "#7D6C58",
            accentHex: "#A77E4E"
        ),
        BackgroundOption(
            id: "plain-white",
            title: "纯白",
            group: "纯色",
            backgroundHex: "#F2F2EE",
            surfaceHex: "#FFFFFF",
            textHex: "#222222",
            secondaryTextHex: "#77736B",
            accentHex: "#8B7A5E"
        ),
        BackgroundOption(
            id: "quiet-dark",
            title: "黑底",
            group: "深色",
            backgroundHex: "#171717",
            surfaceHex: "#242321",
            textHex: "#F7F0E5",
            secondaryTextHex: "#BEB2A2",
            accentHex: "#C9A66B"
        )
    ]
}

struct ToolSheet: View {
    @Binding var activeTool: EditorTool
    @Binding var selectedTemplateID: String
    @Binding var selectedFontPresetID: String
    @Binding var selectedBackgroundID: String
    @Binding var exportPreset: ExportPreset
    @Binding var includesWatermark: Bool

    let template: TemplatePreset
    let pageCount: Int
    let onSave: () -> Void
    let onShare: () -> Void
    let onCopy: () -> Void
    let onMore: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                Capsule()
                    .fill(Color.noteletMutedInk.opacity(0.32))
                    .frame(width: 38, height: 4)
                    .padding(.top, 10)

                sheetHeader

                Group {
                    switch activeTool {
                    case .template:
                        TemplatePanel(selectedTemplateID: $selectedTemplateID)
                    case .font:
                        FontPanel(selectedFontPresetID: $selectedFontPresetID)
                    case .crop:
                        CropPanel(exportPreset: $exportPreset)
                    case .background:
                        BackgroundPanel(
                            selectedBackgroundID: $selectedBackgroundID,
                            includesWatermark: $includesWatermark
                        )
                    case .export:
                        ExportPanel(
                            pageCount: pageCount,
                            onSave: onSave,
                            onShare: onShare,
                            onCopy: onCopy,
                            onMore: onMore
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding(.horizontal, 16)
            .frame(height: 270, alignment: .top)
            .background(.thinMaterial)
            .background(Color.noteletPaper.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.noteletLine, lineWidth: 1)
            }
            .shadow(color: Color.noteletInk.opacity(0.14), radius: 26, x: 0, y: -14)

            ToolDock(activeTool: $activeTool)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var sheetHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(activeTool.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.noteletInk)
            Spacer()
            Text(summary)
                .font(.caption)
                .foregroundStyle(Color.noteletMutedInk)
                .lineLimit(1)
        }
    }

    private var summary: String {
        switch activeTool {
        case .template:
            template.name
        case .font:
            FontPresetStore.builtInPresets.first { $0.id == selectedFontPresetID }?.name ?? "清爽"
        case .crop:
            "\(exportPreset.mode.title) · \(exportPreset.ratio.title)"
        case .background:
            BackgroundOption.options.first { $0.id == selectedBackgroundID }?.title ?? "随模板"
        case .export:
            pageCount == 1 ? "1 张图片" : "共 \(pageCount) 张"
        }
    }
}

private struct ToolDock: View {
    @Binding var activeTool: EditorTool

    var body: some View {
        HStack(spacing: 0) {
            ForEach(EditorTool.allCases) { tool in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        activeTool = tool
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tool.iconName)
                            .font(.system(size: 19, weight: .semibold))
                            .frame(width: 30, height: 24)
                        Text(tool.title)
                            .font(.caption2.weight(activeTool == tool ? .bold : .medium))
                    }
                    .foregroundStyle(activeTool == tool ? Color.noteletInk : Color.noteletMutedInk)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tool.title)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 16)
        .background(Color.noteletPaper)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.noteletLine)
                .frame(height: 1)
        }
    }
}

