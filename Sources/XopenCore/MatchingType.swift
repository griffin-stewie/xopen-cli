import Foundation

public enum MatchingType {
    /// must be exactly same
    case strict
    /// apply patch version if missing. ex: 10.1 == 10.1.0
    case supplement
}

func isMatchXcodeVersion(type: MatchingType, xcodeVersion: String, userSpecificVersion: String) -> Bool {
    switch type {
    case .strict:
        return xcodeVersion == userSpecificVersion
    case .supplement:
        let l = Version(string: xcodeVersion)
        let h = Version(string: userSpecificVersion)
        return l == h
    }
}
