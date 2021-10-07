import Foundation
import ArgumentParser
import Path

extension Path: ExpressibleByArgument {
    public init?(argument: String) {
        self = Path(argument) ?? Path.cwd/argument
    }

    public var defaultValueDescription: String {
        if self == Path.cwd/"." {
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
