// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xopen",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "XopenCore", targets: ["XopenCore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.1.1")),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .upToNextMinor(from: "0.2.5")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.0.2")),
        .package(url: "https://github.com/mxcl/Path.swift.git", .upToNextMinor(from: "1.4.0")),
        .package(url: "https://github.com/sushichop/Puppy", .upToNextMinor(from: "0.5.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "xopen",
            dependencies: [
                "XopenCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
            ]),
        .target(
            name: "XopenCore",
            dependencies: [
                "Stream",
                "Log",
                .product(name: "Path", package: "Path.swift"),
                .product(name: "DequeModule", package: "swift-collections"),
            ]),
        .target(
            name: "Stream",
            dependencies: [
            ]),
        .target(
            name: "Log",
            dependencies: [
                "Stream",
                .product(name: "Puppy", package: "Puppy"),
            ]),
        .testTarget(
            name: "XopenCoreTests",
            dependencies: [
                "XopenCore",
            ]),
    ]
)
