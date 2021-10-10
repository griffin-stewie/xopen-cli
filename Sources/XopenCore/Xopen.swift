import Foundation
import Cocoa

public enum Xopen {

    public static let xcodeVersionFileName = ".xcode-version"

    public static func inspect(url: URL) {
        do {
            let type = try NSWorkspace.shared.type(ofFile: url.path)
            Logger.log("File type: \(type)")
            let defaultAppURL = try defaultApplicationURLForContentType(type: type)
            Logger.log("Default App: \(defaultAppURL)")
        } catch {
            preconditionFailure("\(error)")
        }

        let urls = applicationURLsForURL(url)
        for appURL in urls {
            Logger.log("\(appURL)")
        }
    }

    @discardableResult
    public static func openXcode(with url: URL, targetVersion: UserSpecificXcodeVersion? = nil) throws -> NSRunningApplication {
        let urls = applicationURLsForURL(url)
        let xcodes = urls
            .compactMap({ InstalledXcode($0) })
            .sorted(by: >)

        Logger.log(xcodes)

        if xcodes.isEmpty {
            throw XopenError.noXcodes
        }

        let xcode: InstalledXcode
        if let targetVersion = targetVersion {

            switch targetVersion {
            case .beta:
                if let latestXcode = xcodes.findLatestBeta() {
                    xcode = latestXcode
                } else {
                    throw XopenError.notInstalled(targetVersion.string)
                }
            case .latest:
                if let latestXcode = xcodes.findLatestRelease() {
                    xcode = latestXcode
                } else {
                    throw XopenError.notInstalled(targetVersion.string)
                }
            case .specific(let version):
                if let temp = xcodes.findMatchedXcodeVersion(type: .supplement, userSpecificVersion: targetVersion.string) {
                    print("Use a Xcode(\(targetVersion.string)) that user specified.", to: &standardError)
                    xcode = temp
                } else {
                    throw XopenError.notInstalled(version)
                }
            }
        } else if let specificVersion = readXcodeVersionFile(at: url.deletingLastPathComponent()) {
            if let temp = xcodes.findMatchedXcodeVersion(type: .supplement, userSpecificVersion: specificVersion) {
                print("Use a Xcode(\(specificVersion)) that user specified.", to: &standardError)
                xcode = temp
            } else {
                throw XopenError.notInstalled(specificVersion)
            }
        } else {
            xcode = xcodes.first!
            print("Use the latest Xcode(\(xcode.shortVersion)).", to: &standardError)
        }

        return try NSWorkspace.shared.open(
            [url],
            withApplicationAt: xcode.fileURL,
            options: [.default],
            configuration: [:]
        )
    }
}
