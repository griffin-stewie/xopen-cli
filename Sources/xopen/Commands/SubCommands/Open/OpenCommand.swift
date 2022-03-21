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
            url = try findURLToOpen(under: options.rootDirectoryToFind.url)
        } else {
            url = options.path!.url
        }

        Xopen.inspect(url: url)

        do {
            if options.dryRun {
                print("\(url.absoluteString) will opened by \(String(describing: options.specificVersion))")
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

    private func findURLToOpen(under directoryURL: URL) throws -> URL {
        let pathfinder = Pathfinder()
        return try pathfinder.discoverFileURL(under: directoryURL)
    }
}
