// swift-tools-version:5.5

import Foundation
import PackageDescription

// MARK: - shared

var package = Package(
	name: "AdventOfCode",
	platforms: [
		.macOS(.v12),
	],
	products: [
		.library(name: "Tools", targets: ["Tools"]),
		.executable(name: "VisualizerTestApp", targets: ["VisualizerTestApp"]),
		.executable(name: "Solutions2015", targets: ["Solutions2015"]),
		.executable(name: "Solutions2016", targets: ["Solutions2016"]),
		.executable(name: "Solutions2017", targets: ["Solutions2017"]),
		.executable(name: "Solutions2019", targets: ["Solutions2019"]),
		.executable(name: "Solutions2020", targets: ["Solutions2020"]),
		.executable(name: "Solutions2021", targets: ["Solutions2021"]),
		.executable(name: "Solutions2022", targets: ["Solutions2022"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/mkrd/Swift-BigInt.git", branch: "master"),
		.package(url: "https://github.com/rbruinier/SwiftMicroPNG", branch: "main"),
		.package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.50.4")
	],
	targets: [
		.target(
			name: "Tools",
			dependencies: [
				.product(name: "Collections", package: "swift-collections"),
				.product(name: "MicroPNG", package: "SwiftMicroPNG"),
			],
			resources: [
				.copy("Visualization/Resources"),
			]

		),
		.executableTarget(
			name: "VisualizerTestApp",
			dependencies: [
				"Tools"
			]
		),
		.testTarget(
			name: "ToolsTests",
			dependencies: [
				"Tools",
			]
		),
		.executableTarget(
			name: "Solutions2015",
			dependencies: [
				"Tools",
				.product(name: "Collections", package: "swift-collections"),
			],
			path: "Sources/Solutions/2015",
			resources: [
				.copy("Input"),
			]
		),
		.executableTarget(
			name: "Solutions2016",
			dependencies: [
				"Tools",
				.product(name: "Collections", package: "swift-collections"),
			],
			path: "Sources/Solutions/2016",
			resources: [
				.copy("Input"),
			]
		),
		.executableTarget(
			name: "Solutions2017",
			dependencies: [
				"Tools",
				.product(name: "Collections", package: "swift-collections"),
			],
			path: "Sources/Solutions/2017",
			resources: [
				.copy("Input"),
			]
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
				.copy("Input"),
			]
		),
		.executableTarget(
			name: "Solutions2020",
			dependencies: [
				"Tools",
			],
			path: "Sources/Solutions/2020",
			resources: [
				.copy("Input"),
			]
		),
		.executableTarget(
			name: "Solutions2021",
			dependencies: [
				"Tools",
				.product(name: "Collections", package: "swift-collections")
			],
			path: "Sources/Solutions/2021",
			resources: [
				.copy("Input"),
			]
		),
		.executableTarget(
			name: "Solutions2022",
			dependencies: [
				"Tools",
			],
			path: "Sources/Solutions/2022",
			resources: [
				.copy("Input"),
			]
		),
	]
)
