import Foundation

extension Xopen {
    static func applicationURLsForURL(_ url: URL) -> [URL] {
        guard let cf = LSCopyApplicationURLsForURL(url as CFURL, [.viewer, .editor])?.takeRetainedValue(), let urls = cf as? [URL] else {
            preconditionFailure("unexpected behavior")
        }

        return urls
    }

    static func defaultApplicationURLForContentType(type: String) throws -> URL {
        var error: Unmanaged<CFError>?
        let url = LSCopyDefaultApplicationURLForContentType(type as CFString, .all, &error)?.takeRetainedValue()

        guard error == nil else {
            throw error!.takeRetainedValue()
        }

        return url! as URL
    }


    static func readXcodeVersionFile(at url: URL) -> String? {
        let fileURL = url.appendingPathComponent(xcodeVersionFileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        guard let readString = try? String(contentsOf: fileURL) else {
            return nil
        }

        let version = readString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !version.isEmpty else {
            return nil
        }

        return version
    }
}
