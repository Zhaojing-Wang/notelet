import SwiftUI

struct TemplatePanel: View {
    @Binding var selectedTemplateID: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TemplateStore.builtInTemplates) { template in
                        Button {
                            selectedTemplateID = template.id
                        } label: {
                            TemplateSwatch(template: template, isSelected: selectedTemplateID == template.id)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("选择模板 \(template.name)")
                    }
                }
                .padding(.vertical, 3)
            }

            HStack(spacing: 8) {
                CategoryPill(title: "推荐", isSelected: true)
                CategoryPill(title: "生活", isSelected: false)
                CategoryPill(title: "工作", isSelected: false)
            }
        }
    }
}

struct FontPanel: View {
    @Binding var selectedFontPresetID: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                ForEach(FontPresetStore.builtInPresets) { preset in
                    Button {
                        selectedFontPresetID = preset.id
                    } label: {
                        CategoryPill(title: preset.name, isSelected: selectedFontPresetID == preset.id)
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("字号")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.noteletMutedInk)
                HStack(spacing: 8) {
                    CategoryPill(title: "小", isSelected: false)
                    CategoryPill(title: "标准", isSelected: true)
                    CategoryPill(title: "大", isSelected: false)
                    CategoryPill(title: "超大", isSelected: false)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("行距")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.noteletMutedInk)
                HStack(spacing: 8) {
                    CategoryPill(title: "紧凑", isSelected: false)
                    CategoryPill(title: "标准", isSelected: true)
                    CategoryPill(title: "舒展", isSelected: false)
                }
            }
        }
    }
}

struct CropPanel: View {
    @Binding var exportPreset: ExportPreset

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                modeButton(.singleCard)
                modeButton(.longImage)
                modeButton(.autoPages)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ratioButton(.square1x1)
                ratioButton(.portrait4x5)
                ratioButton(.portrait3x4)
                ratioButton(.story9x16)
            }

            Text(exportPreset.mode == .autoPages ? "自动分页已处理好，可以直接发出去。" : "可以随时切回多图，适合朋友圈和小红书。")
                .font(.footnote)
                .foregroundStyle(Color.noteletMutedInk)
                .padding(.top, 2)
        }
    }

    private func modeButton(_ mode: ExportMode) -> some View {
        Button {
            exportPreset.mode = mode
            if mode == .longImage {
                exportPreset.ratio = .adaptiveLong
            } else if exportPreset.ratio == .adaptiveLong {
                exportPreset.ratio = .portrait4x5
            }
        } label: {
            CategoryPill(title: mode.title, isSelected: exportPreset.mode == mode)
        }
        .buttonStyle(.plain)
    }

    private func ratioButton(_ ratio: ExportRatio) -> some View {
        Button {
            exportPreset.ratio = ratio
            if exportPreset.mode == .longImage {
                exportPreset.mode = .autoPages
            }
        } label: {
            Text(ratio.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(exportPreset.ratio == ratio ? Color.noteletPaper : Color.noteletInk)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(exportPreset.ratio == ratio ? Color.noteletInk : Color.noteletCanvas.opacity(0.78))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("选择比例 \(ratio.title)")
    }
}

struct BackgroundPanel: View {
    @Binding var selectedBackgroundID: String
    @Binding var includesWatermark: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Button {
                    selectedBackgroundID = "template"
                } label: {
                    VStack(spacing: 7) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.noteletPaper)
                            .frame(width: 48, height: 48)
                            .background(Color.noteletCanvas)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(selectedBackgroundID == "template" ? Color.noteletInk : Color.noteletLine, lineWidth: selectedBackgroundID == "template" ? 2 : 1)
                            }
                            .overlay {
                                Image(systemName: "rectangle.3.group")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.noteletMutedInk)
                            }
                        Text("随模板")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Color.noteletMutedInk)
                    }
                }
                .buttonStyle(.plain)

                ForEach(BackgroundOption.options) { option in
                    Button {
                        selectedBackgroundID = option.id
                    } label: {
                        VStack(spacing: 7) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(noteletHex: option.surfaceHex))
                                .frame(width: 48, height: 48)
                                .background(Color(noteletHex: option.backgroundHex))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(selectedBackgroundID == option.id ? Color.noteletInk : Color.noteletLine, lineWidth: selectedBackgroundID == option.id ? 2 : 1)
                                }
                            Text(option.title)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(Color.noteletMutedInk)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Toggle(isOn: $includesWatermark) {
                Label("显示留笺水印", systemImage: "signature")
                    .font(.subheadline.weight(.semibold))
            }
            .tint(Color.noteletInk)
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Color.noteletCanvas.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct ExportPanel: View {
    let pageCount: Int
    let onSave: () -> Void
    let onShare: () -> Void
    let onCopy: () -> Void
    let onMore: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                exportButton("保存相册", systemImage: "square.and.arrow.down", isPrimary: true, action: onSave)
                exportButton("分享给朋友", systemImage: "paperplane", isPrimary: false, action: onShare)
                exportButton("复制图片", systemImage: "doc.on.doc", isPrimary: false, action: onCopy)
                exportButton("更多方式", systemImage: "ellipsis", isPrimary: false, action: onMore)
            }

            Text(pageCount == 1 ? "已生成 1 张图片，可以直接发出去" : "自动分页已处理好，共 \(pageCount) 张")
                .font(.footnote)
                .foregroundStyle(Color.noteletMutedInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(Color.noteletCanvas.opacity(0.62))
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
    }

    private func exportButton(
        _ title: String,
        systemImage: String,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(isPrimary ? Color.noteletPaper : Color.noteletInk)
            .frame(height: 68)
            .frame(maxWidth: .infinity)
            .background(isPrimary ? Color.noteletInk : Color.noteletCanvas.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

private struct TemplateSwatch: View {
    let template: TemplatePreset
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(noteletHex: template.surfaceHex))
                .frame(width: 74, height: 88)
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 5) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(noteletHex: template.textHex))
                            .frame(width: 34, height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(noteletHex: template.textHex).opacity(0.58))
                            .frame(width: 46, height: 4)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(noteletHex: template.accentHex).opacity(0.78))
                            .frame(width: 28, height: 4)
                    }
                    .padding(10)
                }
                .background(Color(noteletHex: template.backgroundHex))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isSelected ? Color.noteletInk : Color.noteletLine, lineWidth: isSelected ? 2 : 1)
                }

            Text(template.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.noteletInk)
                .lineLimit(1)
        }
        .frame(width: 82)
    }
}

private struct CategoryPill: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? Color.noteletPaper : Color.noteletInk)
            .frame(height: 36)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.noteletInk : Color.noteletCanvas.opacity(0.78))
            .clipShape(Capsule())
    }
}
