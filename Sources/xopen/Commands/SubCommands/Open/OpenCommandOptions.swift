import ArgumentParser
import Foundation
import Path
import XopenCore

struct OpenCommandOptions: ParsableArguments {
    @Option(name: .customLong("use"), help: ArgumentHelp("Specific Xcode version you want to use. 'beta' means the latest beta version. 'latest' means the latest release version.", valueName: UserSpecificXcodeVersion.valueNames))
    var specificVersion: UserSpecificXcodeVersion?

    @Option(name: .customLong("use-fallback"), help: ArgumentHelp("Specific Xcode version you want to use when failed to find a specific Xcode.", valueName: UserSpecificXcodeVersion.valueNames))
    var fallbackVersion: UserSpecificXcodeVersion?

    @Flag(help: ArgumentHelp("dry run", visibility: .hidden))
    var dryRun: Bool = false

    @Flag(help: ArgumentHelp("Automatically discovery the file under the current directory to open with Xcode"))
    var autoDiscovery: Bool = false

    @Option(name: .customLong("search-root-dir"), help: ArgumentHelp("Search root directory."))
    var rootDirectoryToFind: Path = Path.cwd / "."

    @Argument(help: ArgumentHelp("Path to the file you want to open in Xcode.", valueName: "file path"), completion: CompletionKind.file(extensions: ["swift", "xcodeproj", "xcworkspace"]))
    var path: Path?

    func validate() throws {
        if !autoDiscovery && path == nil {
            throw ValidationError("You need to give a file path to open or Use `--auto-discovery`")
        }
    }
}
