import Foundation

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

    public static var verbose: Bool = false

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

public var standardError = StandardError()

public struct StandardError: TextOutputStream {
    public mutating func write(_ string: String) {
        for byte in string.utf8 { putc(numericCast(byte), stderr) }
    }
}
