import ArgumentParser
import Foundation
import XopenCore
import Stream

struct HistoryCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "history",
        abstract: "Prints history opened"
    )

    @OptionGroup()
    var options: HistoryCommandOptions

    func run() async throws {
        try await run(options: options)
    }
}

extension HistoryCommand {
    private func run(options: HistoryCommandOptions) async throws {
        do {
            let repo = try HistoryRepository()
            for url in repo.recentDocumentURLs {
                print(url.absoluteURL.path)
            }
        } catch {
            print("Error: \(error)", to: &standardError)
            switch error {
            case XopenError.notInstalled:
                print("not", to: &standardError)
            case XopenError.noXcodes:
                print("Xcode is not installed yet", to: &standardError)
            default:
                print("Error: \(error.localizedDescription)", to: &standardError)
            }
        }
    }
}
