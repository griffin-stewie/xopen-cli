import DequeModule
import Foundation
import Log
import Logging

extension XcodeFilePathfinder {

    /// workspace file extension
    public static let workspacePathExtension: String = "xcworkspace"

    /// xcodeproj file extension
    public static let projectPathExtension: String = "xcodeproj"

    /// Package.swift file name
    public static let packageSwiftFileName: String = "Package.swift"
}

/// Find the file which will be open by Xcode
public final class XcodeFilePathfinder {

    /// Default support file types
    public static let defaultXcodeFileExtensions = [
        workspacePathExtension,
        projectPathExtension,
    ]

    let pathfinder: Pathfinder

    /// Search targets of files to be open
    public let xcodeFileExtensions: [String]

    private var deque: Deque<URL> = Deque()
    private var foundURLs: [URL] = []

    /// Initializer
    /// - Parameters:
    ///   - ignoreDotDirectories: If it's ture, then ignores dot directories, default value is `true`
    ///   - xcodeFileExtensions: Support file types. Default value is `Pathfinder.defaultXcodeFileExtensions`
    public init(ignoreDotDirectories: Bool = true, maxDepth: UInt, xcodeFileExtensions: [String] = XcodeFilePathfinder.defaultXcodeFileExtensions) {
        self.pathfinder = Pathfinder(direction: .lower, maxDepth: maxDepth, ignoreDotDirectories: ignoreDotDirectories)
        self.xcodeFileExtensions = xcodeFileExtensions
    }

    /// Discover file under given direcotry
    /// - Parameter rootDirectoryURL: Search root directory file URL
    /// - Returns: URL found.
    /// - Throws: when not found.
    public func discoverFileURL(under rootDirectoryURL: URL) throws -> URL {
        try pathfinder.discoverFileURL(under: rootDirectoryURL) { (content, isDirectory, depth) throws -> Pathfinder.Operation in
            #if DEBUG
            logger.debug("\(content.absoluteString)")
            #endif

            if let _ = foundURL() {
                return .abort
            }

            if isDirectory {
                for ext in xcodeFileExtensions where ext == content.lastPathComponent.ns.pathExtension {
                    foundURLs.append(content)
                }
                return .continue
            }

            if content.isFile {
                if content.lastPathComponent == XcodeFilePathfinder.packageSwiftFileName {
                    foundURLs.append(content)
                }
                return .continue
            }

            return .continue
        }

        guard let url = foundURL() else {
            throw XopenError.custom("Not found")
        }

        return url
    }
}

extension XcodeFilePathfinder {
    fileprivate func foundURL() -> URL? {
        if foundURLs.isEmpty {
            return nil
        }

        for ext in Self.defaultXcodeFileExtensions {
            let found = foundURLs.first { url in
                url.lastPathComponent.ns.pathExtension == ext
            }

            if let found = found {
                return found
            }
        }

        return foundURLs.first { url in
            url.lastPathComponent == Self.packageSwiftFileName
        }
    }
}
