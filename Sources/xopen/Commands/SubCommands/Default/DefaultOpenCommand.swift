import ArgumentParser
import Foundation
import Path
import XopenCore
import Stream

struct DefaultOpenCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "defaultOpen",
        abstract: "Open file using Xcode version you defined by .xcode-version",
        shouldDisplay: false
    )

    @Option(name: .customLong("use"), help: ArgumentHelp("Specific Xcode version you want to use. 'beta' means the latest beta version. 'latest' means the latest release version.", valueName: UserSpecificXcodeVersion.valueNames))
    var specificVersion: UserSpecificXcodeVersion?

    @Option(name: .customLong("use-fallback"), help: ArgumentHelp("Specific Xcode version you want to use when failed to find a specific Xcode.", valueName: UserSpecificXcodeVersion.valueNames))
    var fallbackVersion: UserSpecificXcodeVersion = .latest

    func run() async throws {
        try await open()
    }
}

extension DefaultOpenCommand {
    private func open() async  throws {
        let rootDirectoryToFind = Path.cwd / "."

        let url = try Xopen.findFileToOpen(under: rootDirectoryToFind.url)

        do {
            try Xopen.openXcode(with: url, targetVersion: specificVersion, fallbackVersion: fallbackVersion)
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
}
