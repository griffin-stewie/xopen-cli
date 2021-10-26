import Foundation
import ArgumentParser
import XopenCore

struct RootCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "xopen",
        abstract: "Open file using Xcode version you defined by .xcode-version",
        version: "1.5.0",
        subcommands: [
            DefaultOpenCommand.self,
            OpenCommand.self,
            HistoryCommand.self,
        ],
        defaultSubcommand: DefaultOpenCommand.self
    )

    @OptionGroup()
    var options: RootCommandOptions

    func validate() throws {
        Logger.verbose = options.verbose
    }
}
