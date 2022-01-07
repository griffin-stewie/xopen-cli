import Foundation

public enum UserSpecificXcodeVersion {
    case beta
    case latest
    case specific(String)
}

extension UserSpecificXcodeVersion {

    /// Returns String representation. It returns Associated Values in case `.specifc(String)`.
    public var string: String {
        switch self {
        case .beta:
            return "beta"
        case .latest:
            return "latest"
        case .specific(let version):
            return version
        }
    }
}

extension UserSpecificXcodeVersion: CustomStringConvertible {
    public var description: String {
        string
    }
}
