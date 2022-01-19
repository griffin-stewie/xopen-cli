import Foundation
import Puppy

final class ConsoleLogFormatter: LogFormattable {
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String : String], label: String, date: Date, threadID: UInt64) -> String {
        let date = dateFormatter(date)
        let file = shortFileName(file)
        let thread = Thread.isMainThread ? "main" : "Thread:\(threadID)"

        switch level {
        case .trace:
            fallthrough
        case .verbose:
            fallthrough
        case .debug:
            fallthrough
        case .info:
            fallthrough
        case .notice:
            fallthrough
        case .warning:
            return "[\(date)] [\(thread)] [\(level.emoji) \(level)] [\(file)#L.\(line) \(function)] \(message)"
        case .error:
            return "[\(level)] \(message)"
        case .critical:
            return "[\(level)] \(message)"
        }
    }
}
