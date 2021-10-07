import Foundation
import ArgumentParser
import XopenCore

extension UserSpecificXcodeVersion: ExpressibleByArgument {
    public init?(argument: String) {
        switch argument.lowercased() {
        case "beta":
            self = .beta
        case "latest":
            self = .latest
        default:
            self = .specific(argument)
        }
    }

    static var valueNames: String {
        "\(UserSpecificXcodeVersion.beta), \(UserSpecificXcodeVersion.latest) or semantic version string"
    }

    static var completionList: [String] {
        let values: [UserSpecificXcodeVersion] = [
            .beta,
            .latest,
            .specific("12.5")
        ]

        return values.map(\.string)
    }

    public var defaultValueDescription: String {
        string
    }

    public static var defaultCompletionKind: CompletionKind {
        return .list(completionList)
    }
}
