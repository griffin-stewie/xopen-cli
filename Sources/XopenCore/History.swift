import Foundation
import Path

// ~/.config/xopen/history.json


/// Configuration
public struct Configuration {
    static let rootDirectoryPath: Path = Path("~/.config/xopen")!
    static let historyJSONFileName: String = "history.json"

    static var historyJSONFilePath: Path {
        rootDirectoryPath / historyJSONFileName
    }

    static func existsConfigRootDirectory() -> Bool {
        return Self.rootDirectoryPath.exists
    }

    static func createConfigRootDirectoryIfNeeds() throws {
        try Self.rootDirectoryPath.mkdir(.p)
    }

    /// a root directory URL
    public static let rootDirectory: URL = rootDirectoryPath.url

    /// history JSON file URL
    public static var historyJSONFileURL: URL {
        (rootDirectoryPath / historyJSONFileName).url
    }
}

/// It manages history.
public struct HistoryRepository {

    var store: HistoryStore = .init()

    /// Returns opened file URLs. Order is the latest first.
    /// - Note: it returns fule path (It starts with like "/Users/xxxxx" )
    public var recentDocumentURLs: [URL] {
        store.recentDocumentURLs.reversed()
    }

    /// Returns opened file URLs. Order is the latest first.
    /// - Note: it returns file URL (file scheme)
    public var recentDocumentFileURLs: [URL] {
        store.recentDocumentURLs
            .map { URL(fileURLWithPath: $0.path) }
            .reversed()
    }


    /// Initialize
    /// - Throws: throws Data load failure or decoding error
    public init() throws {
        guard Configuration.historyJSONFilePath.exists else {
            return
        }

        let decoder = JSONDecoder()
        let data = try Data(contentsOf: Configuration.historyJSONFilePath)
        store = try decoder.decode(HistoryStore.self, from: data)
    }

    /// Add url to history
    /// - Parameter url: file
    /// - Throws: a directory creation error
    public mutating func add(url: URL) throws {
        try Configuration.createConfigRootDirectoryIfNeeds()

        let receatedURL = URL(string: url.absoluteURL.path)!

        if let index = self.store.recentDocumentURLs.firstIndex(of: receatedURL) {
            self.store.recentDocumentURLs.remove(at: index)
        }

        self.store.recentDocumentURLs.append(receatedURL)
    }


    /// Write to file
    /// - Throws: encoding error
    public func save() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(store)
        try data.write(to: Configuration.historyJSONFilePath, atomically: true)
    }
}

struct HistoryStore: Codable {

    /// order is oldest first, latest last.
    var recentDocumentURLs: [URL] = []

    init() {

    }

    enum CodingKeys: String, CodingKey {
        case recentDocumentURLs
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let urls = try values.decode([URL].self, forKey: .recentDocumentURLs)
        self.recentDocumentURLs = urls.reversed()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let paths = recentDocumentURLs.reversed().map { $0.absoluteURL.path }
        try container.encode(paths, forKey: .recentDocumentURLs)
    }
}
