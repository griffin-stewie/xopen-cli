import ArgumentParser
import Foundation
import Path
import XopenCore

struct ReadCommandOptions: ParsableArguments {
    @Option(name: .customLong("search-root-dir"), help: ArgumentHelp("Search root directory."))
    var rootDirectoryToFind: Path = Path.cwd / "."

    @Flag(help: ArgumentHelp("Prints .xcode-version file path which it founds."))
    var printFilePath: Bool = false
}
