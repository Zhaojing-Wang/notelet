import Foundation
import Testing
import UniformTypeIdentifiers
import UIKit
@testable import notelet

struct ItemProviderReaderTests {
    @Test @MainActor func readsTextAndImageAttachmentsIntoOneDocument() async throws {
        let item = NSExtensionItem()
        item.attachments = [
            NSItemProvider(item: "旅行记录\n\n今天看到一张很好看的照片。" as NSString, typeIdentifier: UTType.plainText.identifier),
            NSItemProvider(object: makeImage(size: CGSize(width: 24, height: 12)))
        ]

        let document = await ItemProviderReader.document(from: [item])

        #expect(document?.title == "旅行记录")
        #expect(document?.blocks.count == 2)
        #expect(document?.blocks.first == .paragraph("今天看到一张很好看的照片。"))

        guard case .image(let attachment) = document?.blocks.last else {
            Issue.record("Expected the shared image to become an image block")
            return
        }
        #expect(attachment.aspectRatio == 2)
        #expect(attachment.pixelWidth > attachment.pixelHeight)
        #expect(!attachment.data.isEmpty)
    }

    private func makeImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemRed.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
