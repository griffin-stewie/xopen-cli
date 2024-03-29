import ArgumentParser
import Foundation
import XopenCore
import Stream
import Log

struct OpenCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "open",
        abstract: "Open file using Xcode version you defined by .xcode-version"
    )

    @OptionGroup()
    var options: OpenCommandOptions

    func run() async throws {
        try await run(options: options)
    }
}

extension OpenCommand {
    private func run(options: OpenCommandOptions) async throws {
        let url: URL
        if options.autoDiscovery {
            url = try Xopen.findFileToOpen(under: options.rootDirectoryToFind.url)
        } else {
            url = options.path!.url
        }

        Xopen.inspect(url: url)

        do {
            if options.dryRun {
                let xcode = try Xopen.xcode(with: url, targetVersion: options.specificVersion, fallbackVersion: options.fallbackVersion)
                print("\(url.absoluteString) will opened by \(xcode.version) \(xcode.shortVersion)")
                return
            }

            try Xopen.openXcode(with: url, targetVersion: options.specificVersion, fallbackVersion: options.fallbackVersion)
            var repo = try HistoryRepository()
            try repo.add(url: url)
            try repo.save()
        } catch {
            switch error {
            case XopenError.notInstalled:
                print("Xcode you selected is not installed", to: &standardError)
            case XopenError.noXcodes:
                print("No Xcode is found", to: &standardError)
            default:
                logger.warning("\(error.localizedDescription)")
                logger.error("\(error.localizedDescription)")
            }
        }
    }
}
