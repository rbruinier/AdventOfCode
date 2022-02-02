// swift-tools-version:5.5

import Foundation
import PackageDescription

// MARK: - shared
var package = Package(
    name: "AdventOfCode",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Tools", targets: ["Tools"]),
        .executable(name: "Solutions2019", targets: ["Solutions2019"]),
        .executable(name: "Solutions2020", targets: ["Solutions2020"]),
        .executable(name: "Solutions2021", targets: ["Solutions2021"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/mkrd/Swift-BigInt.git", branch: "master")
    ],
    targets: [
        .target(
            name: "Tools"
        ),
        .executableTarget(
            name: "Solutions2019",
            dependencies: [
                "Tools",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "BigNumber", package: "Swift-BigInt"),
            ],
            path: "Sources/Solutions/2019",
            resources: [
                .copy("Input")
            ]
        ),
        .executableTarget(
            name: "Solutions2020",
            dependencies: [
                "Tools"
            ],
            path: "Sources/Solutions/2020",
            resources: [
                .copy("Input")
            ]
        ),
        .executableTarget(
            name: "Solutions2021",
            dependencies: [
                "Tools"
            ],
            path: "Sources/Solutions/2021",
            resources: [
                .copy("Input")
            ]
        ),
    ]
)
