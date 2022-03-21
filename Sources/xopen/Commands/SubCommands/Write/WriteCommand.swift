import ArgumentParser
import Foundation
import XopenCore
import Stream
import Log
import Path

struct WriteCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "write",
        abstract: "Write `.xcode-version` file"
    )

    @OptionGroup()
    var options: WriteCommandOptions

    func run() throws {
        try run(options: options)
        throw ExitCode.success
    }
}

extension WriteCommand {
    private func run(options: WriteCommandOptions) throws {
        /// 2. Find installed Xcode
        let xcodes = Xopen.installedXcodes()
        let xcode = try xcodes.find(targetVersion: options.specificVersion)
        /// 3. Write .xcode-version file
        try output(xcode, options: options)
    }

    private func output(_ xcode: InstalledXcode, options: WriteCommandOptions) throws {
        let version = String(xcode.versionObject.string) + "\n"
        /// 3. Write .xcode-version file
        if options.writeToStandardOutput {
            print(version, terminator: "")
        } else {
            let path: Path = options.destination/Xopen.xcodeVersionFileName
            try version.write(to: path, encoding: .utf8)
        }
    }
}
