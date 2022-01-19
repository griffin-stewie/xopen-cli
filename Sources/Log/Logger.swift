import Foundation
import Puppy
import Logging
import Stream
import Darwin

public class StderrLogger: BaseLogger {
    public override func log(_ level: LogLevel, string: String) {
        print(string, to: &standardError)
    }
}

public var logger: Logging.Logger = {
    let baseLabel = "net.cyan-stivy.xopen-cli"
    let console = StderrLogger(baseLabel + ".console")
    console.format = ConsoleLogFormatter()

    let puppy = Puppy.default
    puppy.add(console)

    LoggingSystem.bootstrap {
        var handler = PuppyLogHandler(label: $0, puppy: puppy)
        for level in Logger.Level.allCases {
            handler.logLevel = level
        }
        return handler
    }

    let log = Logger(label: baseLabel + ".logger")
    return log
}()
