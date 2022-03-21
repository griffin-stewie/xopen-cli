import ArgumentParser
import Foundation
import Path
import XopenCore

struct WriteCommandOptions: ParsableArguments {
    @Option(name: .customLong("use"), help: ArgumentHelp("Specific Xcode version you want to use. 'beta' means the latest beta version. 'latest' means the latest release version.", valueName: UserSpecificXcodeVersion.valueNames))
    var specificVersion: UserSpecificXcodeVersion = .latest

    @Flag(name: .customLong("to-stdout"), help: ArgumentHelp("Write .xcode-version contents to stdout. `--destination` option will be ignored."))
    var writeToStandardOutput: Bool = false

    @Option(name: .customLong("destination"), help: ArgumentHelp("Destination directory where the .xcode-verion write to."))
    var destination: Path = Path.cwd / "."
}
