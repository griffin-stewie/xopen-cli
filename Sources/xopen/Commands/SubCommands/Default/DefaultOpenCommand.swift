import Foundation
import ArgumentParser
import Path
import XopenCore

struct DefaultOpenCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "defaultOpen",
        abstract: "Open file using Xcode version you defined by .xcode-version",
        shouldDisplay: false
    )

    func run() throws {
        try open()
        throw ExitCode.success
    }
}

extension DefaultOpenCommand {
    private func open() throws {
        let rootDirectoryToFind = Path.cwd/"."

        let url = try findURLToOpen(under: rootDirectoryToFind.url)

        do {
            try Xopen.openXcode(with: url, targetVersion: nil)
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
