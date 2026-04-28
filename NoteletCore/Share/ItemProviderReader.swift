import Foundation
import UniformTypeIdentifiers

public enum ItemProviderReader {
    public static func document(from extensionItems: [NSExtensionItem]) async -> NoteDocument? {
        let providers = extensionItems
            .compactMap(\.attachments)
            .flatMap { $0 }

        for type in preferredTextTypes {
            for provider in providers where provider.hasItemConformingToTypeIdentifier(type.identifier) {
                if let text = await loadText(from: provider, type: type), !text.isEmpty {
                    let source: NoteSource = type == .url ? .url(text) : .shareExtension
                    return NoteParser().parse(text, source: source)
                }
            }
        }

        if providers.contains(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) {
            return NoteDocument(
                title: "图片附件",
                blocks: [.paragraph("留笺第一版主要支持从 Apple Notes 分享文字。图片附件已收到，后续版本会增强图片导入。")],
                source: .shareExtension
            )
        }

        return nil
    }

    private static var preferredTextTypes: [UTType] {
        [.plainText, .text, .url]
    }

    private static func loadText(from provider: NSItemProvider, type: UTType) async -> String? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: type.identifier, options: nil) { item, _ in
                if let string = item as? String {
                    continuation.resume(returning: string.trimmingCharacters(in: .whitespacesAndNewlines))
                    return
                }

                if let url = item as? URL {
                    continuation.resume(returning: url.absoluteString)
                    return
                }

                if let data = item as? Data, let string = String(data: data, encoding: .utf8) {
                    continuation.resume(returning: string.trimmingCharacters(in: .whitespacesAndNewlines))
                    return
                }

                continuation.resume(returning: nil)
            }
        }
    }
}

