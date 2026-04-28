import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct HomeView: View {
    @EnvironmentObject private var historyStore: HistoryStore
    let openEditor: (EditorRoute) -> Void

    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                quickPasteSection
                recentSection
                templateSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .background(
            LinearGradient(
                colors: [.noteletPaper, .noteletCanvas],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("留笺")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("设置")
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("把备忘录变成图片")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(Color.noteletInk)
            Text("从 Apple Notes 分享进来，或直接粘贴文字，快速生成适合社交分享的图片卡片。")
                .font(.body)
                .foregroundStyle(Color.noteletMutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var quickPasteSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("快速开始")
                .font(.headline)
                .foregroundStyle(Color.noteletInk)

            Button {
                openEditor(EditorRoute(document: clipboardDocument()))
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(Color.noteletAccent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("粘贴文字生成")
                            .font(.headline)
                        Text("没有剪贴板内容时，会打开一段示例文字。")
                            .font(.subheadline)
                            .foregroundStyle(Color.noteletMutedInk)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.noteletMutedInk)
                }
                .foregroundStyle(Color.noteletInk)
                .noteletCardStyle()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("粘贴文字生成图片")
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("最近生成")
                    .font(.headline)
                    .foregroundStyle(Color.noteletInk)
                Spacer()
                Text("\(historyStore.records.count)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color.noteletMutedInk)
            }

            if historyStore.records.isEmpty {
                emptyHistory
            } else {
                VStack(spacing: 12) {
                    ForEach(historyStore.records.prefix(6)) { record in
                        HistoryRow(record: record) {
                            openEditor(EditorRoute(record: record))
                        }
                    }
                }
            }
        }
    }

    private var emptyHistory: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("还没有生成记录")
                .font(.headline)
                .foregroundStyle(Color.noteletInk)
            Text("从 Apple Notes 分享文字到留笺，或先用上面的粘贴入口试一张。")
                .font(.subheadline)
                .foregroundStyle(Color.noteletMutedInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .noteletCardStyle()
    }

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("模板推荐")
                .font(.headline)
                .foregroundStyle(Color.noteletInk)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TemplateStore.builtInTemplates.prefix(6)) { template in
                        Button {
                            openEditor(EditorRoute(
                                document: sampleDocument(),
                                templateID: template.id
                            ))
                        } label: {
                            TemplateRecommendationCard(template: template)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(.bottom, 24)
    }

    private func clipboardDocument() -> NoteDocument {
        #if canImport(UIKit)
        let text = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let text, !text.isEmpty {
            return NoteParser().parse(text, source: .clipboard)
        }
        #endif
        return sampleDocument()
    }

    private func sampleDocument() -> NoteDocument {
        NoteDocument(
            title: "从 Apple Notes 分享进来",
            blocks: [
                .paragraph("选择模板、字体和切图方式，然后把这段文字变成可以直接发出去的图片。"),
                .bulletList(["多图默认 4:5", "保存相册", "分享给朋友"]),
                .quote("10 秒内生成一组漂亮图片。")
            ],
            source: .manual
        )
    }
}

private struct HistoryRow: View {
    @EnvironmentObject private var historyStore: HistoryStore
    let record: HistoryRecord
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                thumbnail

                VStack(alignment: .leading, spacing: 4) {
                    Text(record.document.title ?? "未命名留笺")
                        .font(.headline)
                        .lineLimit(1)
                    Text("\(historyStore.template(for: record).name) · \(record.exportPreset.mode.title)")
                        .font(.subheadline)
                        .foregroundStyle(Color.noteletMutedInk)
                    Text(record.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(Color.noteletMutedInk.opacity(0.78))
                }

                Spacer()
                Image(systemName: "arrow.up.message")
                    .foregroundStyle(Color.noteletMutedInk)
            }
            .foregroundStyle(Color.noteletInk)
            .noteletCardStyle(radius: 16)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("重新编辑 \(record.document.title ?? "未命名留笺")")
    }

    @ViewBuilder
    private var thumbnail: some View {
        #if canImport(UIKit)
        if let image = historyStore.thumbnail(for: record) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 54, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            placeholder
        }
        #else
        placeholder
        #endif
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color(noteletHex: historyStore.template(for: record).surfaceHex))
            .frame(width: 54, height: 68)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.noteletLine, lineWidth: 1)
            }
    }
}

private struct TemplateRecommendationCard: View {
    let template: TemplatePreset

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: CGFloat(template.cornerRadius) / 3, style: .continuous)
                .fill(Color(noteletHex: template.surfaceHex))
                .frame(width: 112, height: 140)
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 7) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(noteletHex: template.textHex))
                            .frame(width: 52, height: 8)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(noteletHex: template.textHex).opacity(0.62))
                            .frame(width: 74, height: 5)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(noteletHex: template.accentHex).opacity(0.8))
                            .frame(width: 42, height: 5)
                    }
                    .padding(16)
                }
                .background(Color(noteletHex: template.backgroundHex))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.noteletInk.opacity(0.08), radius: 12, x: 0, y: 8)

            Text(template.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.noteletInk)
            Text(template.category.title)
                .font(.caption)
                .foregroundStyle(Color.noteletMutedInk)
        }
        .frame(width: 132, alignment: .leading)
    }
}
