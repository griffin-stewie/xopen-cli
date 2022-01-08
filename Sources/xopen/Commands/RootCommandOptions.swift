import ArgumentParser
import Foundation
import Path

struct RootCommandOptions: ParsableArguments {
    @Flag()
    var verbose: Bool = false
}
