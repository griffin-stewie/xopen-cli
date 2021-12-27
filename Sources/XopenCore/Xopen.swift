import Foundation
import Cocoa

public enum Xopen {

    public static let xcodeVersionFileName = ".xcode-version"

    public static func inspect(url: URL) {
        do {
            _ = try defaultApplicationURLFor(url: url)
        } catch {
            preconditionFailure("\(error)")
        }

        let urls = applicationURLsForURL(url)
        for appURL in urls {
            Logger.log("\(appURL)")
        }
    }

    @discardableResult
    public static func openXcode(with url: URL, targetVersion: UserSpecificXcodeVersion? = nil, fallbackVersion: UserSpecificXcodeVersion? = nil) throws -> NSRunningApplication {
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
            xcode = try xcodes.find(targetVersion: targetVersion)
        } else if let xcodeVersionURL = findXcodeVersionFile(openFileURL: url),
                  let specificVersion = readXcodeVersionFile(at: xcodeVersionURL) {
            if let temp = xcodes.findMatchedXcodeVersion(type: .supplement, userSpecificVersion: specificVersion) {
                print("Use a Xcode(\(specificVersion)) that user specified.", to: &standardError)
                xcode = temp
            } else {
                throw XopenError.notInstalled(specificVersion)
            }
        } else if let fallbackVersion = fallbackVersion {
            xcode = try xcodes.find(targetVersion: fallbackVersion)
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
