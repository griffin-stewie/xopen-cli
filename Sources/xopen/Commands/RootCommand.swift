import Foundation
import ArgumentParser
import XopenCore

struct RootCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "xopen",
        abstract: "Open file using Xcode version you defined by .xcode-version",
        version: "1.4.0",
        subcommands: [
            OpenCommand.self,
            HistoryCommand.self
        ],
        defaultSubcommand: OpenCommand.self
    )

    @OptionGroup()
    var options: RootCommandOptions

    func validate() throws {
        Logger.verbose = options.verbose
    }
}
