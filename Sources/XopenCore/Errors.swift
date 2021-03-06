import Foundation

/// Xopen's Error
public enum XopenError: Error {
    case noXcodes
    case notInstalled(String)
    case custom(String)
}

extension XopenError: LocalizedError {

    /// Error description
    public var errorDescription: String? {
        switch self {
        case .noXcodes:
            return "Xcode is not installed"
        case .notInstalled(let version):
            return "Could not be found the Xcode (version: \(version)) you specified"
        case .custom(let string):
            return string
        }
    }

    /// helpAnchor
    public var helpAnchor: String? {
        return nil
    }

    /// recoverySuggestion
    public var recoverySuggestion: String? {
        return nil
    }
}
