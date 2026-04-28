import Foundation

public struct NoteParser {
    public init() {}

    public func parse(
        _ rawText: String,
        source: NoteSource = .shareExtension,
        identifiesFirstLineAsTitle: Bool = true
    ) -> NoteDocument {
        let normalized = rawText.replacingOccurrences(of: "\r\n", with: "\n")
        let lines = normalized.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var cursor = 0
        var title: String?

        if identifiesFirstLineAsTitle {
            while cursor < lines.count, lines[cursor].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                cursor += 1
            }
            if cursor < lines.count {
                let candidate = lines[cursor].trimmingCharacters(in: .whitespacesAndNewlines)
                if !candidate.isEmpty {
                    title = stripHeadingMarkup(candidate).text
                    cursor += 1
                }
            }
        }

        var blocks: [NoteBlock] = []
        var paragraphLines: [String] = []
        var bulletItems: [String] = []
        var numberedItems: [String] = []
        var quoteLines: [String] = []

        func flushParagraph() {
            guard !paragraphLines.isEmpty else { return }
            blocks.append(.paragraph(paragraphLines.joined(separator: "\n")))
            paragraphLines.removeAll()
        }

        func flushBullets() {
            guard !bulletItems.isEmpty else { return }
            blocks.append(.bulletList(bulletItems))
            bulletItems.removeAll()
        }

        func flushNumbered() {
            guard !numberedItems.isEmpty else { return }
            blocks.append(.numberedList(numberedItems))
            numberedItems.removeAll()
        }

        func flushQuote() {
            guard !quoteLines.isEmpty else { return }
            blocks.append(.quote(quoteLines.joined(separator: "\n")))
            quoteLines.removeAll()
        }

        func flushInlineGroups() {
            flushParagraph()
            flushBullets()
            flushNumbered()
            flushQuote()
        }

        while cursor < lines.count {
            let rawLine = lines[cursor]
            let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            cursor += 1

            if trimmed.isEmpty {
                flushInlineGroups()
                continue
            }

            if isDivider(trimmed) {
                flushInlineGroups()
                blocks.append(.divider)
                continue
            }

            let heading = Self.heading(from: trimmed)
            if let heading {
                flushInlineGroups()
                blocks.append(.heading(heading.text, level: heading.level))
                continue
            }

            if let bullet = Self.bulletItem(from: trimmed) {
                flushParagraph()
                flushNumbered()
                flushQuote()
                bulletItems.append(bullet)
                continue
            }

            if let numbered = Self.numberedItem(from: trimmed) {
                flushParagraph()
                flushBullets()
                flushQuote()
                numberedItems.append(numbered)
                continue
            }

            if let quote = Self.quoteText(from: trimmed) {
                flushParagraph()
                flushBullets()
                flushNumbered()
                quoteLines.append(quote)
                continue
            }

            flushBullets()
            flushNumbered()
            flushQuote()
            paragraphLines.append(trimmed)
        }

        flushInlineGroups()

        return NoteDocument(title: title, blocks: blocks, source: source)
    }

    private func stripHeadingMarkup(_ line: String) -> (text: String, level: Int?) {
        guard let heading = Self.heading(from: line) else {
            return (line, nil)
        }
        return (heading.text, heading.level)
    }

    private static func heading(from line: String) -> (text: String, level: Int)? {
        let prefix = line.prefix { $0 == "#" }
        guard !prefix.isEmpty, prefix.count <= 3 else { return nil }
        let remainder = line.dropFirst(prefix.count)
        guard remainder.first == " " else { return nil }
        let text = remainder.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        return (text, prefix.count)
    }

    private static func bulletItem(from line: String) -> String? {
        let markers = ["- ", "• ", "* "]
        for marker in markers where line.hasPrefix(marker) {
            let value = line.dropFirst(marker.count).trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty ? nil : value
        }
        return nil
    }

    private static func numberedItem(from line: String) -> String? {
        var index = line.startIndex
        var sawDigit = false
        while index < line.endIndex, line[index].isNumber {
            sawDigit = true
            index = line.index(after: index)
        }
        guard sawDigit, index < line.endIndex, line[index] == "." || line[index] == ")" else {
            return nil
        }
        let afterMarker = line.index(after: index)
        guard afterMarker < line.endIndex, line[afterMarker].isWhitespace else {
            return nil
        }
        let text = line[afterMarker...].trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private static func quoteText(from line: String) -> String? {
        guard line.hasPrefix(">") else { return nil }
        let text = line.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private func isDivider(_ line: String) -> Bool {
        guard line.count >= 3 else { return false }
        return line.allSatisfy { $0 == "-" || $0 == "—" || $0 == "_" }
    }
}

