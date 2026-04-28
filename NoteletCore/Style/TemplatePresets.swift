import Foundation

public enum TemplateCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case minimal
    case paper
    case reading
    case social
    case dark
    case sticky
    case work

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .minimal:
            "极简"
        case .paper:
            "纸张"
        case .reading:
            "读书"
        case .social:
            "社交"
        case .dark:
            "深色"
        case .sticky:
            "便签"
        case .work:
            "工作"
        }
    }
}

public struct TemplatePreset: Codable, Equatable, Identifiable, Hashable {
    public let id: String
    public var name: String
    public var category: TemplateCategory
    public var backgroundHex: String
    public var surfaceHex: String
    public var textHex: String
    public var secondaryTextHex: String
    public var accentHex: String
    public var cornerRadius: Double
    public var padding: Double
    public var paragraphSpacing: Double
    public var watermarkDefault: Bool

    public init(
        id: String,
        name: String,
        category: TemplateCategory,
        backgroundHex: String,
        surfaceHex: String,
        textHex: String,
        secondaryTextHex: String,
        accentHex: String,
        cornerRadius: Double = 18,
        padding: Double = 72,
        paragraphSpacing: Double = 24,
        watermarkDefault: Bool = true
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.backgroundHex = backgroundHex
        self.surfaceHex = surfaceHex
        self.textHex = textHex
        self.secondaryTextHex = secondaryTextHex
        self.accentHex = accentHex
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.paragraphSpacing = paragraphSpacing
        self.watermarkDefault = watermarkDefault
    }
}

public struct FontPreset: Codable, Equatable, Identifiable, Hashable {
    public enum FontRole: String, Codable, CaseIterable, Hashable {
        case system
        case rounded
        case serif
        case monospaced
    }

    public let id: String
    public var name: String
    public var titleRole: FontRole
    public var bodyRole: FontRole
    public var titleScale: Double
    public var bodyScale: Double
    public var lineSpacing: Double
    public var titleWeight: String
    public var bodyWeight: String

    public init(
        id: String,
        name: String,
        titleRole: FontRole,
        bodyRole: FontRole,
        titleScale: Double,
        bodyScale: Double,
        lineSpacing: Double,
        titleWeight: String = "semibold",
        bodyWeight: String = "regular"
    ) {
        self.id = id
        self.name = name
        self.titleRole = titleRole
        self.bodyRole = bodyRole
        self.titleScale = titleScale
        self.bodyScale = bodyScale
        self.lineSpacing = lineSpacing
        self.titleWeight = titleWeight
        self.bodyWeight = bodyWeight
    }
}

public enum TemplateStore {
    public static let builtInTemplates: [TemplatePreset] = [
        TemplatePreset(
            id: "minimal-white",
            name: "极简白",
            category: .minimal,
            backgroundHex: "#F4EFE7",
            surfaceHex: "#FFFDF8",
            textHex: "#28241F",
            secondaryTextHex: "#817360",
            accentHex: "#B38B58"
        ),
        TemplatePreset(
            id: "warm-paper",
            name: "纸张感",
            category: .paper,
            backgroundHex: "#EFE2CF",
            surfaceHex: "#FAF1E1",
            textHex: "#302820",
            secondaryTextHex: "#7D6C58",
            accentHex: "#A77E4E"
        ),
        TemplatePreset(
            id: "reading-quote",
            name: "读书摘录",
            category: .reading,
            backgroundHex: "#F2ECE2",
            surfaceHex: "#FFFDF7",
            textHex: "#2A2621",
            secondaryTextHex: "#786D5F",
            accentHex: "#8B6F47",
            paragraphSpacing: 28
        ),
        TemplatePreset(
            id: "social-card",
            name: "小红书卡片",
            category: .social,
            backgroundHex: "#F7E8E0",
            surfaceHex: "#FFF8F4",
            textHex: "#2B2521",
            secondaryTextHex: "#805F55",
            accentHex: "#C45C4D",
            cornerRadius: 26,
            padding: 68
        ),
        TemplatePreset(
            id: "quiet-dark",
            name: "黑底高级感",
            category: .dark,
            backgroundHex: "#171717",
            surfaceHex: "#242321",
            textHex: "#F7F0E5",
            secondaryTextHex: "#BEB2A2",
            accentHex: "#C9A66B",
            cornerRadius: 20
        ),
        TemplatePreset(
            id: "sticky-note",
            name: "便签风",
            category: .sticky,
            backgroundHex: "#F4E7BC",
            surfaceHex: "#FFF1B8",
            textHex: "#352B1F",
            secondaryTextHex: "#876E45",
            accentHex: "#D0A83E",
            cornerRadius: 12,
            padding: 64
        ),
        TemplatePreset(
            id: "letter-paper",
            name: "信笺风",
            category: .paper,
            backgroundHex: "#ECE5D8",
            surfaceHex: "#FFFDF6",
            textHex: "#2F2A23",
            secondaryTextHex: "#817669",
            accentHex: "#B8A27A",
            cornerRadius: 10,
            padding: 76
        ),
        TemplatePreset(
            id: "work-summary",
            name: "工作卡片",
            category: .work,
            backgroundHex: "#EAEDE8",
            surfaceHex: "#FBFCFA",
            textHex: "#232A25",
            secondaryTextHex: "#657068",
            accentHex: "#607A64",
            cornerRadius: 16,
            padding: 66
        )
    ]

    public static let defaultTemplate = builtInTemplates[0]
}

public enum FontPresetStore {
    public static let builtInPresets: [FontPreset] = [
        FontPreset(
            id: "clean",
            name: "清爽",
            titleRole: .rounded,
            bodyRole: .system,
            titleScale: 1.2,
            bodyScale: 1,
            lineSpacing: 1.15
        ),
        FontPreset(
            id: "reading",
            name: "阅读",
            titleRole: .serif,
            bodyRole: .serif,
            titleScale: 1.18,
            bodyScale: 1.02,
            lineSpacing: 1.28
        ),
        FontPreset(
            id: "journal",
            name: "手帐",
            titleRole: .rounded,
            bodyRole: .rounded,
            titleScale: 1.16,
            bodyScale: 1,
            lineSpacing: 1.22
        ),
        FontPreset(
            id: "work",
            name: "工具",
            titleRole: .system,
            bodyRole: .system,
            titleScale: 1.12,
            bodyScale: 0.98,
            lineSpacing: 1.1,
            titleWeight: "bold"
        )
    ]

    public static let defaultPreset = builtInPresets[0]
}
