import SwiftUI

#if canImport(UIKit)
import Photos
import UIKit
#endif

enum EditorTool: String, CaseIterable, Identifiable {
    case template
    case font
    case crop
    case background
    case export

    var id: String { rawValue }

    var title: String {
        switch self {
        case .template:
            "模板"
        case .font:
            "字体"
        case .crop:
            "切图"
        case .background:
            "背景"
        case .export:
            "导出"
        }
    }

    var iconName: String {
        switch self {
        case .template:
            "rectangle.on.rectangle"
        case .font:
            "textformat"
        case .crop:
            "rectangle.split.2x1"
        case .background:
            "paintpalette"
        case .export:
            "square.and.arrow.up"
        }
    }
}

struct EditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var historyStore: HistoryStore

    let document: NoteDocument
    private let onCancel: (() -> Void)?

    @State private var selectedTemplateID: String
    @State private var selectedFontPresetID: String
    @State private var selectedBackgroundID: String = "template"
    @State private var exportPreset: ExportPreset
    @State private var activeTool: EditorTool = .template
    @State private var includesWatermark = true
    @State private var alertMessage: String?
    @State private var isShareSheetPresented = false
    @State private var shareItems: [Any] = []

    init(route: EditorRoute, onCancel: (() -> Void)? = nil) {
        self.document = route.document
        self.onCancel = onCancel
        _selectedTemplateID = State(initialValue: route.templateID)
        _selectedFontPresetID = State(initialValue: route.fontPresetID)
        _exportPreset = State(initialValue: route.exportPreset)
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                topBar
                previewArea
                Spacer(minLength: 0)
            }
            .padding(.bottom, 340)

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ToolSheet(
                    activeTool: $activeTool,
                    selectedTemplateID: $selectedTemplateID,
                    selectedFontPresetID: $selectedFontPresetID,
                    selectedBackgroundID: $selectedBackgroundID,
                    exportPreset: $exportPreset,
                    includesWatermark: $includesWatermark,
                    template: effectiveTemplate,
                    pageCount: previewPages.count,
                    onSave: saveImages,
                    onShare: shareImages,
                    onCopy: copyImages,
                    onMore: shareImages
                )
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .alert("留笺", isPresented: alertBinding) {
            Button("好", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ActivityView(activityItems: shareItems)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(noteletHex: effectiveTemplate.surfaceHex),
                Color(noteletHex: effectiveTemplate.backgroundHex)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay {
            GeometryReader { proxy in
                Path { path in
                    let step: CGFloat = 42
                    var x: CGFloat = 0
                    while x < proxy.size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                        x += step
                    }
                }
                .stroke(Color.noteletInk.opacity(0.025), lineWidth: 1)
            }
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack {
            Button("取消") {
                if let onCancel {
                    onCancel()
                } else {
                    dismiss()
                }
            }
            .font(.body.weight(.medium))
            .foregroundStyle(Color.noteletMutedInk)
            .frame(minWidth: 44, minHeight: 44, alignment: .leading)

            Spacer()

            VStack(spacing: 2) {
                Text("留笺")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.noteletInk)
                Text("\(previewPages.count) 张图片")
                    .font(.caption)
                    .foregroundStyle(Color.noteletMutedInk)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    activeTool = .export
                }
            } label: {
                Text("导出")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(noteletHex: effectiveTemplate.surfaceHex))
                    .padding(.horizontal, 14)
                    .frame(minHeight: 34)
                    .background(Color.noteletInk)
                    .clipShape(Capsule())
            }
            .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
            .accessibilityLabel("打开导出面板")
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
    }

    private var previewArea: some View {
        GeometryReader { proxy in
            TabView {
                ForEach(previewPages) { page in
                    scaledCard(page: page, in: proxy.size)
                        .padding(.horizontal, 24)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: previewPages.count > 1 ? .automatic : .never))
        }
        .padding(.top, 8)
    }

    private func scaledCard(page: RenderedPage, in availableSize: CGSize) -> some View {
        let maxWidth = max(availableSize.width - 48, 120)
        let maxHeight = max(availableSize.height - 36, 160)
        let scale = min(maxWidth / page.size.width, maxHeight / page.size.height)

        return NoteCardView(
            document: page.document,
            template: effectiveTemplate,
            fontPreset: selectedFontPreset,
            exportSize: page.size,
            includesWatermark: includesWatermark
        )
        .scaleEffect(scale)
        .frame(width: page.size.width * scale, height: page.size.height * scale)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.noteletInk.opacity(0.22), radius: 26, x: 0, y: 18)
        .accessibilityLabel("图片预览")
    }

    private var previewPages: [RenderedPage] {
        RenderPlanner.pages(for: currentRequest)
    }

    private var currentRequest: RenderRequest {
        RenderRequest(
            document: document,
            template: effectiveTemplate,
            fontPreset: selectedFontPreset,
            exportPreset: exportPreset,
            includesWatermark: includesWatermark
        )
    }

    private var selectedTemplate: TemplatePreset {
        TemplateStore.builtInTemplates.first { $0.id == selectedTemplateID } ?? TemplateStore.defaultTemplate
    }

    private var selectedFontPreset: FontPreset {
        FontPresetStore.builtInPresets.first { $0.id == selectedFontPresetID } ?? FontPresetStore.defaultPreset
    }

    private var effectiveTemplate: TemplatePreset {
        var template = selectedTemplate
        if let background = BackgroundOption.options.first(where: { $0.id == selectedBackgroundID }) {
            template.backgroundHex = background.backgroundHex
            template.surfaceHex = background.surfaceHex
            template.textHex = background.textHex
            template.secondaryTextHex = background.secondaryTextHex
            template.accentHex = background.accentHex
        }
        return template
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )
    }

    private func renderImages() -> [UIImage] {
        ImageExportService().renderImages(for: currentRequest)
    }

    private func saveImages() {
        Task {
            let images = renderImages()
            guard !images.isEmpty else {
                alertMessage = "暂时没有可导出的图片"
                return
            }

            do {
                try await PhotoLibraryExporter.save(images)
                remember(images: images)
                alertMessage = images.count == 1 ? "已保存到相册" : "已保存 \(images.count) 张图片到相册"
            } catch {
                alertMessage = "保存相册失败，请检查照片权限"
            }
        }
    }

    private func shareImages() {
        let images = renderImages()
        guard !images.isEmpty else {
            alertMessage = "暂时没有可分享的图片"
            return
        }
        remember(images: images)
        shareItems = images
        isShareSheetPresented = true
    }

    private func copyImages() {
        let images = renderImages()
        guard !images.isEmpty else {
            alertMessage = "暂时没有可复制的图片"
            return
        }
        UIPasteboard.general.images = images
        remember(images: images)
        alertMessage = images.count == 1 ? "已复制图片" : "已复制 \(images.count) 张图片"
    }

    private func remember(images: [UIImage]) {
        let thumbnailPath = images.first.flatMap { historyStore.saveThumbnail($0) }
        historyStore.add(HistoryRecord(
            document: document,
            templateID: selectedTemplateID,
            fontPresetID: selectedFontPresetID,
            exportPreset: exportPreset,
            thumbnailPath: thumbnailPath
        ))
    }
}

#if canImport(UIKit)
private enum PhotoLibraryExporter {
    static func save(_ images: [UIImage]) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw CocoaError(.userCancelled)
        }

        try await PHPhotoLibrary.shared().performChanges {
            for image in images {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
}
#endif
