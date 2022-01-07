import Foundation

let XcodeBundleIdentifier = "com.apple.dt.Xcode"

final class InstalledXcode {

    let fileURL: URL

    private let infoDictionary: [String: Any]

    private let versionPlist: VersionPlist

    let bundleIdentifier: String

    var shortVersion: String {
        return versionPlist.shortVersion
    }

    var version: Double {
        return versionPlist.version
    }

    var isBeta: Bool {
        fileURL.lastPathComponent.lowercased().contains("beta")
    }

    init?(_ fileURL: URL) {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        guard let bundleIdentifier = Bundle.init(path: fileURL.path).flatMap({ $0.bundleIdentifier }) else {
            return nil
        }

        guard bundleIdentifier == XcodeBundleIdentifier else {
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
            Logger.log("\(obj)")
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
    var description: String {
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
    static func == (lhs: InstalledXcode, rhs: InstalledXcode) -> Bool {
        return lhs.version == rhs.version
    }

    static func < (lhs: InstalledXcode, rhs: InstalledXcode) -> Bool {
        return lhs.version < rhs.version
    }
}

extension Array where Element == InstalledXcode {
    func find(targetVersion: UserSpecificXcodeVersion) throws -> Element {
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

    func findLatestBeta() -> Element? {
        return first(where: { $0.isBeta })
    }

    func findLatestRelease() -> Element? {
        return first(where: { !$0.isBeta })
    }

    func findMatchedXcodeVersion(type: MatchingType, userSpecificVersion: String) -> Element? {
        return first(where: {
            isMatchXcodeVersion(type: type, xcodeVersion: $0.shortVersion, userSpecificVersion: userSpecificVersion)
        })
    }
}
