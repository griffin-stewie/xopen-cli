import Foundation
import Log

extension XcodeVersionFilePathfinder {
    public static let xcodeVersionFileName: String = Xopen.xcodeVersionFileName
}

public final class XcodeVersionFilePathfinder {

    let pathfinder: Pathfinder

    public init(direction: Pathfinder.Direction = .upper, ignoreDotDirectories: Bool = true, maxDepth: UInt) {
        self.pathfinder = Pathfinder(direction: direction, maxDepth: maxDepth, ignoreDotDirectories: ignoreDotDirectories)
    }

    public func discoverXcodeVersionFile(startFrom directoryURL: URL) throws -> URL {
        var foundURL: URL? = nil

        try self.pathfinder.discoverFileURL(under: directoryURL) { (content, isDirectory) throws -> Pathfinder.Operation in
            #if DEBUG
            logger.debug("\(content.absoluteString)")
            print("\(content.absoluteString)")
            #endif

            if content.isFile {
                if content.lastPathComponent == Self.xcodeVersionFileName {
                    foundURL = content
                    return .abort
                }
            }

            if isDirectory {
                if content.lastPathComponent == ".git" {
                    return .skipDirectory(content)
                }
            }

            return .continue
        }


        guard let url = foundURL else {
            throw XopenError.custom("Not found")
        }

        return url
    }
}
