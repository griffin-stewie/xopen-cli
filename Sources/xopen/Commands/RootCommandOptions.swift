import Foundation
import ArgumentParser
import Path

struct RootCommandOptions: ParsableArguments {
    @Flag()
    var verbose: Bool = false
}
