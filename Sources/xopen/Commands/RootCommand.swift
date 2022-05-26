import ArgumentParser
import Foundation
import XopenCore
import Log

@main
struct RootCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "xopen",
        abstract: "Open file using Xcode version you defined by .xcode-version",
        version: "1.7.0",
        subcommands: [
            DefaultOpenCommand.self,
            OpenCommand.self,
            HistoryCommand.self,
            WriteCommand.self,
            ReadCommand.self,
        ],
        defaultSubcommand: DefaultOpenCommand.self
    )

    @OptionGroup()
    var options: RootCommandOptions

    func validate() throws {
        logger.logLevel = options.logLevel()
    }
}
