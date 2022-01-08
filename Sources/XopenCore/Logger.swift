import Foundation

/// Logger
public struct Logger {

    //    public static var debug: Logger {
    //        Logger(verbose: true)
    //    }
    //
    //    public static var logger: Logger {
    //        Logger(verbose: false)
    //    }
    //
    //    public static var shard: Logger = Logger(verbose: false)

    /// verbose option
    public static var verbose: Bool = false

    /// log
    /// - Parameters:
    ///   - message: message
    ///   - file: file name
    ///   - function: function name
    ///   - line: line number
    public static func log(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        guard verbose else {
            return
        }

        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let text = """
            [\(Date())][\(fileName) / \(line):\(function)] \(message)
            """
        print(text, to: &standardError)
    }
}

/// Standard error output shared instance
public var standardError = StandardError()

/// Standard error output
public struct StandardError: TextOutputStream {

    /// Write given String into stderr
    /// - Parameter string: The String which will be write into stderr.
    public mutating func write(_ string: String) {
        for byte in string.utf8 { putc(numericCast(byte), stderr) }
    }
}
