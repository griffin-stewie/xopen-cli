import Foundation
import ArgumentParser
import XopenCore

struct OpenCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "open",
        abstract: "Open file using Xcode version you defined by .xcode-version"
    )

    @OptionGroup()
    var options: OpenCommandOptions

    func run() throws {
        try run(options: options)
        throw ExitCode.success
    }
}

extension OpenCommand {
    private func run(options: OpenCommandOptions) throws {
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
            
            try Xopen.openXcode(with: url, targetVersion: options.specificVersion)
            var repo = try HistoryRepository()
            try repo.add(url: url)
            try repo.save()
        } catch {
            print("Error: \(error)", to: &standardError)
            switch error {
            case XopenError.notInstalled:
                print("Xcode you selected is not installed", to: &standardError)
            case XopenError.noXcodes:
                print("No Xcode is found", to: &standardError)
            default:
                print("Error: \(error.localizedDescription)", to: &standardError)
            }
        }
    }
    
    private func findURLToOpen(under directoryURL: URL) throws -> URL {
        let pathfinder = Pathfinder()
        return try pathfinder.discoverFileURL(under: directoryURL)
    }
}
