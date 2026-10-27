// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Logy",
    platforms: [
        .macOS(.v15), .iOS(.v18),
    ],
    products: [
        .library(
            name: "Logy",
            targets: ["Logy"]),
    ],
    targets: [
        .target(name: "Logy"),
        .testTarget(
            name: "LogyTests",
            dependencies: ["Logy"]
        ),
    ]
)
