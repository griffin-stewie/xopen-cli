import Foundation

extension XcodeVersionFilePathfinder {
    static let xcodeVersionFileName: String = Xopen.xcodeVersionFileName
}

final class XcodeVersionFilePathfinder {

    let ignoreDotDirectories: Bool
    let maxDepth: UInt

    init(ignoreDotDirectories: Bool = true, maxDepth: UInt) {
        self.ignoreDotDirectories = ignoreDotDirectories
        self.maxDepth = maxDepth
    }

    func discoverXcodeVersionFile(startFrom directoryURL: URL) throws -> URL {
        let url = try traverse(from: directoryURL, maxDepth: self.maxDepth)

        guard let url = url else {
            throw XopenError.custom("Not found")
        }

        return url
    }
}

extension XcodeVersionFilePathfinder {
    // Breadth-First Search
    fileprivate func traverse(from targetDirectoryURL: URL, maxDepth: UInt) throws -> URL? {
        let fs = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants]
        let contents = try fs.contentsOfDirectory(at: targetDirectoryURL, includingPropertiesForKeys: nil, options: options)

        var isGitRepositoryRootDir: Bool = false

        for content in contents {
            #if DEBUG
                print(content.absoluteString)
            #endif

            if content.isFile {
                if content.lastPathComponent == Self.xcodeVersionFileName {
                    return content
                }
            }

            if content.isDirectory {
                if content.lastPathComponent == ".git" {
                    isGitRepositoryRootDir = true
                }
            }
        }

        if maxDepth == 0 {
            return nil
        }

        if isGitRepositoryRootDir {
            return nil
        }

        guard let nextTargetDir = targetDirectoryURL.parent else {
            return nil
        }

        return try traverse(from: nextTargetDir, maxDepth: maxDepth - 1)
    }

    fileprivate func depth(at targetDirectoryURL: URL, rootDirectoryURL: URL) -> UInt {
        let t = targetDirectoryURL.pathComponents.count
        let r = rootDirectoryURL.pathComponents.count

        precondition(t >= r, "pathComponents.count is illegal")

        return UInt(t - r)
    }
}
