import Foundation
import Darwin

/// Standard error output shared instance
public var standardError = StandardError()

/// Standard error output
public struct StandardError: TextOutputStream {

    public init() { }

    /// Write given String into stderr
    /// - Parameter string: The String which will be write into stderr.
    public mutating func write(_ string: String) {
        for byte in string.utf8 { putc(numericCast(byte), stderr) }
    }
}
