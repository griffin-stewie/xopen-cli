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
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.0.1")),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .upToNextMinor(from: "0.2.4")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/mxcl/Path.swift.git", .upToNextMinor(from: "1.4.0")),
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
                .product(name: "Path", package: "Path.swift"),
                .product(name: "DequeModule", package: "swift-collections"),
            ]),
        .testTarget(
            name: "xopenTests",
            dependencies: ["xopen"]),
        .testTarget(
            name: "XopenCoreTests",
            dependencies: [
                "XopenCore",
                .product(name: "Path", package: "Path.swift"),
            ]),
    ]
)
