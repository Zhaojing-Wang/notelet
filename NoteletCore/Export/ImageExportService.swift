import SwiftUI

#if canImport(UIKit)
import UIKit

@MainActor
public struct ImageExportService {
    public init() {}

    public func renderImages(for request: RenderRequest) -> [UIImage] {
        RenderPlanner.pages(for: request).compactMap { page in
            let content = NoteCardView(
                document: page.document,
                template: request.template,
                fontPreset: request.fontPreset,
                exportSize: page.size,
                includesWatermark: request.includesWatermark
            )

            let renderer = ImageRenderer(content: content)
            renderer.scale = request.exportPreset.scale
            return renderer.uiImage
        }
    }
}
#endif

