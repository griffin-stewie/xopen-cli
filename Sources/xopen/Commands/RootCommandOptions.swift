import ArgumentParser
import Foundation
import Path
import Logging

struct RootCommandOptions: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Verbose defaults to zero, and counts the number of times that -v or --verbose is given.")
    var verbose: Int
}

extension RootCommandOptions {
    func logLevel() -> Logging.Logger.Level {
        switch verbose {
        case 0:
            return .error
        case 1:
            return .notice
        case 2:
            return .info
        case 3:
            return .debug
        default:
            return .trace
        }
    }
}
