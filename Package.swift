// swift-tools-version:5.7
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
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.2.0"),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", exact: "0.4.0"),
        .package(url: "https://github.com/apple/swift-collections.git", exact: "1.0.4"),
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.4.4"),
        .package(url: "https://github.com/mxcl/Path.swift.git", exact: "1.4.0"),
        .package(url: "https://github.com/griffin-stewie/Bucker", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "xopen",
            dependencies: [
                "XopenCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .target(
            name: "XopenCore",
            dependencies: [
                "Stream",
                "Log",
                .product(name: "DequeModule", package: "swift-collections"),
                .product(name: "Path", package: "Path.swift"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
            ]),
        .target(
            name: "Stream",
            dependencies: [
            ]),
        .target(
            name: "Log",
            dependencies: [
                "Stream",
                .product(name: "Logging", package: "swift-log"),
            ]),
        .testTarget(
            name: "XopenCoreTests",
            dependencies: [
                "XopenCore",
                .product(name: "Bucker", package: "Bucker"),
            ]),
    ]
)
