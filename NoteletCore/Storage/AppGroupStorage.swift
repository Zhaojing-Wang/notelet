import Foundation

public enum AppGroupStorage {
    public static let groupIdentifier = "group.wang.zhaojing.notelet"

    public static var containerURL: URL {
        if let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupIdentifier
        ) {
            return appGroupURL
        }

        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents
    }

    public static func ensureDirectory(_ name: String) throws -> URL {
        let directory = containerURL.appendingPathComponent(name, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        return directory
    }
}

