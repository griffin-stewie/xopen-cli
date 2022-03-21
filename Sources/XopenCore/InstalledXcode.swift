import Foundation
import Stream
import Log

let xcodeBundleIdentifier = "com.apple.dt.Xcode"

public final class InstalledXcode {

    public let fileURL: URL

    private let infoDictionary: [String: Any]

    private let versionPlist: VersionPlist

    public let bundleIdentifier: String

    public var shortVersion: String {
        return versionPlist.shortVersion
    }

    public var version: Double {
        return versionPlist.version
    }

    public var versionObject: Version {
        return Version(string: shortVersion)
    }

    public var isBeta: Bool {
        fileURL.lastPathComponent.lowercased().contains("beta")
    }

    public init?(_ fileURL: URL) {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        guard let bundleIdentifier = Bundle.init(path: fileURL.path).flatMap({ $0.bundleIdentifier }) else {
            return nil
        }

        guard bundleIdentifier == xcodeBundleIdentifier else {
            return nil
        }

        self.bundleIdentifier = bundleIdentifier

        self.fileURL = fileURL
        let plistURL = self.fileURL.appendingPathComponent("Contents").appendingPathComponent("version.plist")

        guard FileManager.default.fileExists(atPath: plistURL.path) else {
            return nil
        }

        do {
            let data = try Data.init(contentsOf: plistURL)
            let obj = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            logger.debug("\(obj)")
            guard let info = obj as? [String: Any] else {
                return nil
            }
            self.infoDictionary = info
            versionPlist = try PropertyListDecoder().decode(VersionPlist.self, from: data)
        } catch {
            print("\(error)", to: &standardError)
            return nil
        }
    }
}

extension InstalledXcode: CustomStringConvertible {
    public var description: String {
        return """
            {
            \turl: \(fileURL),
            \tshortVersion: \(shortVersion),
            \tversion: \(version)
            }
            """
    }
}

extension InstalledXcode: Equatable, Comparable {
    public static func == (lhs: InstalledXcode, rhs: InstalledXcode) -> Bool {
        return lhs.version == rhs.version
    }

    public static func < (lhs: InstalledXcode, rhs: InstalledXcode) -> Bool {
        return lhs.version < rhs.version
    }
}

extension Array where Element == InstalledXcode {
    public func find(targetVersion: UserSpecificXcodeVersion) throws -> Element {
        let element: Element
        switch targetVersion {
        case .beta:
            if let latestXcode = findLatestBeta() {
                element = latestXcode
            } else {
                throw XopenError.notInstalled(targetVersion.string)
            }
        case .latest:
            if let latestXcode = findLatestRelease() {
                element = latestXcode
            } else {
                throw XopenError.notInstalled(targetVersion.string)
            }
        case .specific(let version):
            if let temp = findMatchedXcodeVersion(type: .supplement, userSpecificVersion: targetVersion.string) {
                print("Use a Xcode(\(targetVersion.string)) that user specified.", to: &standardError)
                element = temp
            } else {
                throw XopenError.notInstalled(version)
            }
        }

        return element
    }

    public func findLatestBeta() -> Element? {
        return first(where: { $0.isBeta })
    }

    public func findLatestRelease() -> Element? {
        return first(where: { !$0.isBeta })
    }

    public func findMatchedXcodeVersion(type: MatchingType, userSpecificVersion: String) -> Element? {
        return first(where: {
            isMatchXcodeVersion(type: type, xcodeVersion: $0.shortVersion, userSpecificVersion: userSpecificVersion)
        })
    }
}
