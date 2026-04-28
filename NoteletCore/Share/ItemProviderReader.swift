import Foundation
import UniformTypeIdentifiers
import UIKit

public enum ItemProviderReader {
    public static func document(from extensionItems: [NSExtensionItem]) async -> NoteDocument? {
        let providers = extensionItems
            .compactMap(\.attachments)
            .flatMap { $0 }

        for type in preferredTextTypes {
            for provider in providers where provider.hasItemConformingToTypeIdentifier(type.identifier) {
                if let text = await loadText(from: provider, type: type), !text.isEmpty {
                    let source: NoteSource = type == .url ? .url(text) : .shareExtension
                    var document = NoteParser().parse(text, source: source)
                    document.blocks.append(contentsOf: await loadImages(from: providers).map(NoteBlock.image))
                    return document
                }
            }
        }

        let images = await loadImages(from: providers)
        if !images.isEmpty {
            return NoteDocument(
                title: "图片附件",
                blocks: images.map(NoteBlock.image),
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

    private static func loadImages(from providers: [NSItemProvider]) async -> [NoteImageAttachment] {
        var images: [NoteImageAttachment] = []
        for provider in providers where provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            if let image = await loadImage(from: provider) {
                images.append(image)
            }
        }
        return images
    }

    private static func loadImage(from provider: NSItemProvider) async -> NoteImageAttachment? {
        if provider.canLoadObject(ofClass: UIImage.self),
           let image = await loadUIImage(from: provider),
           let attachment = makeAttachment(from: image, typeIdentifier: preferredImageType(from: provider)) {
            return attachment
        }

        for typeIdentifier in provider.registeredTypeIdentifiers where UTType(typeIdentifier)?.conforms(to: .image) == true {
            if let attachment = await loadImageData(from: provider, typeIdentifier: typeIdentifier) {
                return attachment
            }
        }

        return nil
    }

    private static func loadUIImage(from provider: NSItemProvider) async -> UIImage? {
        await withCheckedContinuation { continuation in
            provider.loadObject(ofClass: UIImage.self) { object, _ in
                continuation.resume(returning: object as? UIImage)
            }
        }
    }

    private static func loadImageData(from provider: NSItemProvider, typeIdentifier: String) async -> NoteImageAttachment? {
        await withCheckedContinuation { continuation in
            provider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, _ in
                guard let data, let image = UIImage(data: data) else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: NoteImageAttachment(
                    data: data,
                    typeIdentifier: typeIdentifier,
                    pixelWidth: image.size.width * image.scale,
                    pixelHeight: image.size.height * image.scale
                ))
            }
        }
    }

    private static func makeAttachment(from image: UIImage, typeIdentifier: String) -> NoteImageAttachment? {
        guard let data = image.jpegData(compressionQuality: 0.9) ?? image.pngData() else {
            return nil
        }

        return NoteImageAttachment(
            data: data,
            typeIdentifier: typeIdentifier,
            pixelWidth: image.size.width * image.scale,
            pixelHeight: image.size.height * image.scale
        )
    }

    private static func preferredImageType(from provider: NSItemProvider) -> String {
        provider.registeredTypeIdentifiers.first { UTType($0)?.conforms(to: .image) == true }
            ?? UTType.jpeg.identifier
    }
}
