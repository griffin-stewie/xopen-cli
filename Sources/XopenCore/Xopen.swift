import Cocoa
import Foundation
import Stream
import Log

public enum Xopen {

    /// .xocde-version file name
    public static let xcodeVersionFileName = ".xcode-version"

    /// Prints support app locations for debug purpose
    /// - Parameter url: A file URL to be inspect.
    public static func inspect(url: URL) {
        do {
            _ = try defaultApplicationURLFor(url: url)
        } catch {
            preconditionFailure("\(error)")
        }

        let urls = applicationURLsForURL(url)
        for appURL in urls {
            logger.debug("\(appURL)")
        }
    }

    /// Open a file by Xcode
    /// - Parameters:
    ///   - url: A file URL you want to open by Xcode
    ///   - targetVersion: Xcode version you want to use
    ///   - fallbackVersion: Xcode version you want to use if no xcode-version
    /// - Returns: NSRunningApplication.
    /// - Throws: error.
    @discardableResult
    public static func openXcode(with url: URL, targetVersion: UserSpecificXcodeVersion? = nil, fallbackVersion: UserSpecificXcodeVersion? = nil) throws -> NSRunningApplication {
        let urls = applicationURLsForURL(url)
        let xcodes =
            urls
            .compactMap({ InstalledXcode($0) })
            .sorted(by: >)

        logger.debug("\(xcodes)")

        if xcodes.isEmpty {
            throw XopenError.noXcodes
        }

        let xcode: InstalledXcode
        if let targetVersion = targetVersion {
            xcode = try xcodes.find(targetVersion: targetVersion)
        } else if let xcodeVersionURL = findXcodeVersionFile(openFileURL: url), let specificVersion = readXcodeVersionFile(at: xcodeVersionURL) {
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
