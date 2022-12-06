import DequeModule
import Foundation
import Log
import Logging

extension Pathfinder {

    /// workspace file extension
    public static let workspacePathExtension: String = "xcworkspace"

    /// xcodeproj file extension
    public static let projectPathExtension: String = "xcodeproj"

    /// Package.swift file name
    public static let packageSwiftFileName: String = "Package.swift"
}

/// Find the file which will be open by Xcode
public final class Pathfinder {

    public enum Operation {
        case `continue`
        case skipDirectory(URL)
        case abort
    }

    public enum Direction {
        case lower
        case upper
    }

    public typealias TraverseHandler = (_ content: URL, _ isDirectory: Bool, _ depth: UInt) throws -> Operation


    /// To ignore dot directories, set true.
    public let ignoreDotDirectories: Bool

    let maxDepth: UInt
    let direction: Direction

    private var deque: Deque<URL> = Deque()

    /// Initializer
    /// - Parameters:
    ///   - ignoreDotDirectories: If it's ture, then ignores dot directories, default value is `true`
    ///   - xcodeFileExtensions: Support file types. Default value is `Pathfinder.defaultXcodeFileExtensions`
    public init(direction: Direction, maxDepth: UInt, ignoreDotDirectories: Bool = true) {
        self.direction = direction
        self.maxDepth = maxDepth
        self.ignoreDotDirectories = ignoreDotDirectories
    }

    /// Discover file under given direcotry
    /// - Parameter rootDirectoryURL: Search root directory file URL
    /// - Returns: URL found.
    /// - Throws: when not found.
    public func discoverFileURL(under rootDirectoryURL: URL, handler: TraverseHandler) throws {
        switch direction {
        case .lower:
            try traverseToLower(at: rootDirectoryURL, rootDirectoryURL: rootDirectoryURL, maxDepth: maxDepth, handler: handler)
        case .upper:
            try traverseToUpper(from: rootDirectoryURL, maxDepth: maxDepth, handler: handler)
        }

    }
}

extension Pathfinder {
    // Breadth-First Search
    fileprivate func traverseToLower(at targetDirectoryURL: URL, rootDirectoryURL: URL, maxDepth: UInt, handler: TraverseHandler) throws {
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants]
        let fs = FileManager.default
        let contents = try fs.contentsOfDirectory(at: targetDirectoryURL, includingPropertiesForKeys: nil, options: options)

        // Exit recursive calls if no contents
        guard !contents.isEmpty else {
            return
        }

        for content in contents {
            #if DEBUG
                logger.debug("\(content.absoluteString)")
            #endif

            if ignoreDotDirectories && content.isDirectory && content.lastPathComponent.hasPrefix(".") {
                continue
            }

            let ops = try handler(content, content.isDirectory, maxDepth)

            switch ops {
            case .continue:
                if content.isDirectory {
                    deque.append(content)
                }
                continue
            case .skipDirectory(let url):
                if content != url, content.isDirectory {
                    deque.append(content)
                }
            case .abort:
                return
            }
        }

        guard let nextTargetDir = deque.popFirst() else {
            return
        }

        if maxDepth == 0 {
            return
        }

        return try traverseToLower(at: nextTargetDir, rootDirectoryURL: rootDirectoryURL, maxDepth: maxDepth - 1, handler: handler)
    }

    fileprivate func traverseToUpper(from targetDirectoryURL: URL, maxDepth: UInt, handler: TraverseHandler) throws {
        let fs = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants]
        let contents = try fs.contentsOfDirectory(at: targetDirectoryURL, includingPropertiesForKeys: nil, options: options)

        for content in contents {
            #if DEBUG
            logger.debug("\(content.absoluteString)")
            print("\(content.absoluteString)")
            #endif

            if ignoreDotDirectories && content.isDirectory && content.lastPathComponent.hasPrefix(".") {
                continue
            }

            let ops = try handler(content, content.isDirectory, maxDepth)

            switch ops {
            case .continue:
                if content.isDirectory {
                    deque.append(content)
                }
                continue
            case .skipDirectory:
                break
            case .abort:
                return
            }
        }

        if maxDepth == 0 {
            return
        }

        guard let nextTargetDir = targetDirectoryURL.parent else {
            return
        }

        return try traverseToUpper(from: nextTargetDir, maxDepth: maxDepth - 1, handler: handler)
    }
}

extension Pathfinder {
    fileprivate func debugPrint<T: Collection>(collection: T, label: String? = nil) -> String {
        var str = ""
        print("debugPrint label:\(label ?? "nil") {", to: &str)
        for a in collection {
            print("\t\(a)", to: &str)
        }
        print("}", to: &str)

        return str
    }

    fileprivate func debugPrint<T: Collection>(collection: T, label: String? = nil) -> Logger.Message {
        var str = ""
        print("debugPrint label:\(label ?? "nil") {", to: &str)
        for a in collection {
            print("\t\(a)", to: &str)
        }
        print("}", to: &str)

        return Logger.Message.init(stringLiteral: str)
    }
}
