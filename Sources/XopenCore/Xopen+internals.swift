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

    /// Find ".xcode-version" file around given URL
    /// - Parameter openFileURL: The URL of the file to be opened by Xcode, such as "Package.swift", "XXX.xcworkspace", or "XXX.xcproj".
    /// - Returns: ".xcode-version" file URL

    /// Find ".xcode-version" file around given URL
    /// - Parameters:
    ///   - openFileURL: The URL of the file to be opened by Xcode, such as "Package.swift", "XXX.xcworkspace", or "XXX.xcproj".
    ///   - maxDepth: maximam depth to go up
    /// - Returns: ".xcode-version" file URL
    static func findXcodeVersionFile(openFileURL: URL, maxDepth: UInt = 4) -> URL? {
        // First, Try the target exists at same directory.
        let dirURL = openFileURL.deletingLastPathComponent()
//        let xcodeVersionFileURL = dirURL.appendingPathComponent(xcodeVersionFileName)
//        if FileManager.default.fileExists(atPath: xcodeVersionFileURL.path) {
//            return xcodeVersionFileURL
//        }

        // Second, Try the target exists upper level but the limit is repository root.
        let a = XcodeVersionFilePathfinder(maxDepth: maxDepth)
        return try? a.discoverXcodeVersionFile(startFrom: dirURL)
    }

    static func isInsideGitRepository(at url: URL) -> Bool {
        let (status, output) = FileManager.default.chdir(url.path) {
            return shell("git", "rev-parse", "--is-inside-work-tree")
        }

        return status == EXIT_SUCCESS && output.lowercased().hasPrefix("true")
    }
}

@discardableResult
fileprivate func shell(_ args: String...) -> (Int32, String) {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return (task.terminationStatus, output)
}
