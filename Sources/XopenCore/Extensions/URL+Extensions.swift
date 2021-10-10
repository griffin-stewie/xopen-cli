import Foundation

public extension URL {
    /// Returns true if the path represents an actual filesystem entry that is *not* a directory.
    var isFile: Bool {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && !isDir.boolValue
    }

    /// Returns true if the path represents an actual directory.
    var isDirectory: Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
    }

    var parent: URL? {
        let deleted = self.deletingLastPathComponent()
        if deleted == self {
            return nil
        }

        return deleted
    }
}
