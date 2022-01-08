import ArgumentParser
import Foundation
import Path

extension Path: ExpressibleByArgument {

    /// Initializer to confirm `ExpressibleByArgument`
    public init?(argument: String) {
        self = Path(argument) ?? Path.cwd / argument
    }

    /// `defaultValueDescription` to confirm `ExpressibleByArgument`
    public var defaultValueDescription: String {
        if self == Path.cwd / "." {
            return "current directory"
        }

        return String(describing: self)
    }
}


extension URL {
    func basename(dropExtension: Bool) -> String {
        guard let p = Path(url: self) else {
            preconditionFailure("file URL expected")
        }

        return p.basename(dropExtension: dropExtension)
    }
}
