import Foundation
import Log

extension XcodeVersionFilePathfinder {
    public static let xcodeVersionFileName: String = Xopen.xcodeVersionFileName
}

public final class XcodeVersionFilePathfinder {

    let pathfinder: Pathfinder

    public init(ignoreDotDirectories: Bool = true, maxDepth: UInt) {
        self.pathfinder = Pathfinder(direction: .upper, maxDepth: maxDepth, ignoreDotDirectories: ignoreDotDirectories)
    }

    public func discoverXcodeVersionFile(startFrom directoryURL: URL) throws -> URL {
        var foundURL: URL? = nil
        var isGitRepositoryRootDir: Bool = false
        try self.pathfinder.discoverFileURL(under: directoryURL) { (content, isDirectory) throws -> Pathfinder.Operation in
            #if DEBUG
            logger.debug("\(content.absoluteString)")
            print("\(content.absoluteString)")
            #endif

            if isGitRepositoryRootDir {
                return .abort
            }

            if content.isFile {
                if content.lastPathComponent == Self.xcodeVersionFileName {
                    foundURL = content
                    return .abort
                }
            }

            if isDirectory {
                if content.lastPathComponent == ".git" {
                    isGitRepositoryRootDir = true
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
