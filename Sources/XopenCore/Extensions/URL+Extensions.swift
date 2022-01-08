import Foundation

extension URL {
    /// Returns true if the path represents an actual filesystem entry that is *not* a directory.
    public var isFile: Bool {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && !isDir.boolValue
    }

    /// Returns true if the path represents an actual directory.
    public var isDirectory: Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
    }

    /// Returns parent directory if possible.
    public var parent: URL? {
        let deleted = self.deletingLastPathComponent()
        if deleted == self {
            return nil
        }

        return deleted
    }
}
