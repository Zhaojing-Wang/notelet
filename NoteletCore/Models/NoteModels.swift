import CoreGraphics
import Foundation

public struct NoteDocument: Codable, Equatable, Identifiable, Hashable {
    public let id: UUID
    public var title: String?
    public var blocks: [NoteBlock]
    public var source: NoteSource
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String?,
        blocks: [NoteBlock],
        source: NoteSource,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.blocks = blocks
        self.source = source
        self.createdAt = createdAt
    }
}

public enum NoteSource: Codable, Equatable, Hashable {
    case shareExtension
    case clipboard
    case manual
    case url(String)
}

public enum NoteBlock: Codable, Equatable, Hashable, Identifiable {
    case heading(String, level: Int)
    case paragraph(String)
    case bulletList([String])
    case numberedList([String])
    case quote(String)
    case divider

    public var id: String {
        switch self {
        case .heading(let text, let level):
            "heading-\(level)-\(text.hashValue)"
        case .paragraph(let text):
            "paragraph-\(text.hashValue)"
        case .bulletList(let items):
            "bullet-\(items.hashValue)"
        case .numberedList(let items):
            "numbered-\(items.hashValue)"
        case .quote(let text):
            "quote-\(text.hashValue)"
        case .divider:
            "divider"
        }
    }
}

public enum ExportMode: String, Codable, CaseIterable, Identifiable, Hashable {
    case singleCard
    case longImage
    case autoPages
    case manualPages

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .singleCard:
            "单张"
        case .longImage:
            "长图"
        case .autoPages:
            "多图"
        case .manualPages:
            "手动分页"
        }
    }
}

public enum ExportRatio: String, Codable, CaseIterable, Identifiable, Hashable {
    case square1x1
    case portrait4x5
    case portrait3x4
    case story9x16
    case adaptiveLong

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .square1x1:
            "1:1"
        case .portrait4x5:
            "4:5"
        case .portrait3x4:
            "3:4"
        case .story9x16:
            "9:16"
        case .adaptiveLong:
            "长图"
        }
    }

    public func size(width: CGFloat, contentHeight: CGFloat? = nil) -> CGSize {
        switch self {
        case .square1x1:
            CGSize(width: width, height: width)
        case .portrait4x5:
            CGSize(width: width, height: width * 5 / 4)
        case .portrait3x4:
            CGSize(width: width, height: width * 4 / 3)
        case .story9x16:
            CGSize(width: width, height: width * 16 / 9)
        case .adaptiveLong:
            CGSize(width: width, height: max(contentHeight ?? width * 1.25, width * 1.25))
        }
    }
}

public struct ExportPreset: Codable, Equatable, Hashable {
    public var mode: ExportMode
    public var ratio: ExportRatio
    public var width: CGFloat
    public var scale: CGFloat

    public init(
        mode: ExportMode,
        ratio: ExportRatio,
        width: CGFloat = 1080,
        scale: CGFloat = 2
    ) {
        self.mode = mode
        self.ratio = ratio
        self.width = width
        self.scale = scale
    }

    public static let defaultSocial = ExportPreset(mode: .autoPages, ratio: .portrait4x5)
}

