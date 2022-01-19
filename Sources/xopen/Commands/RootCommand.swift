import ArgumentParser
import Foundation
import XopenCore
import Log

struct RootCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "xopen",
        abstract: "Open file using Xcode version you defined by .xcode-version",
        version: "1.6.1",
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
        logger.logLevel = options.logLevel()
    }
}
