import Foundation
import Logging
import Stream
import Darwin

public var logger: Logging.Logger = {
    let baseLabel = "net.cyan-stivy.xopen-cli"
    LoggingSystem.bootstrap {
        MultiplexLogHandler([
            StreamLogHandler.standardError(label: $0)
        ])
    }

    let log = Logger(label: baseLabel + ".logger")
    return log
}()
