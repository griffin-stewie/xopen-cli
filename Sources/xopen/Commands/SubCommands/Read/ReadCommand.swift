import ArgumentParser
import Foundation
import XopenCore
import Stream
import Log
import Path

struct ReadCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Read `.xcode-version` file"
    )

    @OptionGroup()
    var options: ReadCommandOptions

    func run() async throws {
        try await run(options: options)
    }
}

extension ReadCommand {
    private func run(options: ReadCommandOptions) async throws {
        let finder = XcodeVersionFilePathfinder(maxDepth: 3)
        let xcodeVersionFileURL = try finder.discoverXcodeVersionFile(startFrom: options.rootDirectoryToFind.url)

        if options.printFilePath {
            print("\(xcodeVersionFileURL.path)")
        }

        guard let content = Xopen.readXcodeVersionFile(at: xcodeVersionFileURL) else {
            print("Could not read `.xcode-version` file", to: &standardError)
            return
        }

        print(content)
    }
}
