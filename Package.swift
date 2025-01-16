// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReLogger",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ReLogger", targets: ["ReLogger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.2"),
    ],
    targets: [
        .target(name: "ReLogger", dependencies: [
            .product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(
            name: "ReLoggerTests",
            dependencies: ["ReLogger"]
        ),
    ]
)
