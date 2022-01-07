import DequeModule
import Foundation

extension Pathfinder {
    public static let workspacePathExtension: String = "xcworkspace"
    public static let projectPathExtension: String = "xcodeproj"
    public static let packageSwiftFileName: String = "Package.swift"
}

public final class Pathfinder {

    public static let defaultXcodeFileExtensions = [
        workspacePathExtension,
        projectPathExtension,
    ]

    public let ignoreDotDirectories: Bool
    public let xcodeFileExtensions: [String]

    private var deque: Deque<URL> = Deque()
    private var foundURLs: [URL] = []

    public init(ignoreDotDirectories: Bool = true, xcodeFileExtensions: [String] = Pathfinder.defaultXcodeFileExtensions) {
        self.ignoreDotDirectories = ignoreDotDirectories
        self.xcodeFileExtensions = xcodeFileExtensions
    }

    public func discoverFileURL(under rootDirectoryURL: URL) throws -> URL {
        let url = try traverse(at: rootDirectoryURL, rootDirectoryURL: rootDirectoryURL)

        guard let url = url else {
            throw XopenError.custom("Not found")
        }

        return url
    }
}

extension Pathfinder {
    // Breadth-First Search
    fileprivate func traverse(at targetDirectoryURL: URL, rootDirectoryURL: URL) throws -> URL? {
        let fs = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
        let contents = try fs.contentsOfDirectory(at: targetDirectoryURL, includingPropertiesForKeys: nil, options: options)

        for content in contents {
            #if DEBUG
                print(content.absoluteString)
            #endif

            if content.isDirectory {
                deque.append(content)
                for ext in xcodeFileExtensions {
                    if content.lastPathComponent.ns.pathExtension == ext {
                        foundURLs.append(content)
                    }
                }
            }

            if content.isFile {
                if content.lastPathComponent == "Package.swift" {
                    foundURLs.append(content)
                }
            }
        }

        #if DEBUG
            debugPrint(collection: deque, label: "Deque")
            debugPrint(collection: foundURLs, label: "Found so far")
        #endif

        guard let nextTargetDir = deque.popFirst() else {
            return foundURL()
        }

        if willChangeDepth(currentTarget: targetDirectoryURL, nextTarget: nextTargetDir, rootDirectoryURL: rootDirectoryURL) {
            if let found = foundURL() {
                // When the depth of directory changes, return the URL if the search target has already been found.
                return found
            }
        }

        return try traverse(at: nextTargetDir, rootDirectoryURL: rootDirectoryURL)
    }

    fileprivate func willChangeDepth(currentTarget currentTargetDirectoryURL: URL, nextTarget nextTargetDirectoryURL: URL, rootDirectoryURL: URL) -> Bool {
        let currentDepth = depth(at: currentTargetDirectoryURL, rootDirectoryURL: rootDirectoryURL)
        let nextDepth = depth(at: nextTargetDirectoryURL, rootDirectoryURL: rootDirectoryURL)
        return currentDepth < nextDepth
    }

    fileprivate func depth(at targetDirectoryURL: URL, rootDirectoryURL: URL) -> UInt {
        let t = targetDirectoryURL.pathComponents.count
        let r = rootDirectoryURL.pathComponents.count

        precondition(t >= r, "pathComponents.count is illegal")

        return UInt(t - r)
    }

    fileprivate func foundURL() -> URL? {
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

    fileprivate func debugPrint<T: Collection>(collection: T, label: String? = nil) {
        print("debugPrint label:\(label ?? "nil") {")
        for a in collection {
            print("\t\(a)")
        }
        print("}")
    }
}
