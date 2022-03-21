import Foundation

public struct Version {
    public let majorVersion: Int
    public let minorVersion: Int
    public let patchVersion: Int

    public var string: String {
        "\(majorVersion).\(minorVersion).\(patchVersion)"
    }
}

extension Version: Equatable {
}

extension Version {
    init(string version: String) {
        let result = Version.split(version)
        majorVersion = result.first
        minorVersion = result.second
        patchVersion = result.third
    }

    private static func split(_ string: String) -> (first: Int, second: Int, third: Int) {
        let compo = string.components(separatedBy: ".").compactMap(Int.init)
        switch compo.count {
        case 1:
            return (first: compo[0], second: 0, third: 0)
        case 2:
            return (first: compo[0], second: compo[1], third: 0)
        case 3:
            return (first: compo[0], second: compo[1], third: compo[2])
        default:
            return (first: 0, second: 0, third: 0)
        }
    }
}

extension Version: CustomStringConvertible {

    /// description
    public var description: String {
        string
    }
}
