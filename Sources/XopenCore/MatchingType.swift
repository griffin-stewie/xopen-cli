import Foundation
import TSCUtility

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
        let l = try! Version(versionString: xcodeVersion, usesLenientParsing: true)
        let h = try! Version(versionString: userSpecificVersion, usesLenientParsing: true)
        return l == h
    }
}
