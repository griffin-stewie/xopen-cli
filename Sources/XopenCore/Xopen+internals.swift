import AppKit
import Foundation
import UniformTypeIdentifiers
import Log

extension Xopen {
    static func applicationURLsForURL(_ url: URL) -> [URL] {
        if #available(macOS 12.0, *) {
            return NSWorkspace.shared.urlsForApplications(toOpen: url)
        } else {
            guard let cf = LSCopyApplicationURLsForURL(url as CFURL, [.viewer, .editor])?.takeRetainedValue(), let urls = cf as? [URL] else {
                preconditionFailure("unexpected behavior")
            }

            return urls
        }
    }

    static func defaultApplicationURLForContentType(type: String) throws -> URL {
        var error: Unmanaged<CFError>?
        let url = LSCopyDefaultApplicationURLForContentType(type as CFString, .all, &error)?.takeRetainedValue()

        guard error == nil else {
            throw error!.takeRetainedValue()
        }

        return url! as URL
    }

    static func defaultApplicationURLFor(url: URL) throws -> URL {
        if #available(macOS 12.0, *) {
            let values = try url.resourceValues(forKeys: [.contentTypeKey])
            let type = values.contentType!
            logger.debug("File type: \(type)")
            let defaultAppURL = NSWorkspace.shared.urlForApplication(toOpen: type)!
            logger.debug("Default App: \(defaultAppURL)")
            return defaultAppURL
        } else {
            let type = try NSWorkspace.shared.type(ofFile: url.path)
            logger.debug("File type: \(type)")
            let defaultAppURL = try defaultApplicationURLForContentType(type: type)
            logger.debug("Default App: \(defaultAppURL)")
            return defaultAppURL
        }
    }

    static func applicationsURLsToOpenXcodeProj() -> [URL] {
        if #available(macOS 12.0, *) {
            guard let type = UTType("com.apple.xcode.project") else {
                return []
            }

            let urls = NSWorkspace.shared.urlsForApplications(toOpen: type)
            logger.debug("URLs to open \(type.identifier): \(urls)")
            return urls
        } else {
            let fs = FileManager.default
            do {
                /// 1. Write dummy xcodeproj file to find installed Xcodes.
                ///
                let tempDir = fs.temporaryDirectory
                let dummyXcodeProjURL = tempDir.appendingPathComponent("dummy.xcodeproj")
                try fs.createDirectory(at: dummyXcodeProjURL, withIntermediateDirectories: false)
                defer {
                    try? fs.removeItem(at: dummyXcodeProjURL)
                }

                /// 2. Find installed Xcode
                let urls = applicationURLsForURL(dummyXcodeProjURL)
                logger.debug("URLs to open \(dummyXcodeProjURL.absoluteString): \(urls)")
                return urls
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    static func readXcodeVersionFile(at url: URL) -> String? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        guard let readString = try? String(contentsOf: url) else {
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
private func shell(_ args: String...) -> (Int32, String) {
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
