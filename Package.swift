// swift-tools-version:6.0

import Foundation
import PackageDescription

// MARK: - shared

var package = Package(
	name: "AdventOfCode",
	platforms: [
		.macOS(.v15),
	],
	products: [
		.library(name: "Tools", targets: ["Tools"]),
		.executable(name: "Examples", targets: ["Examples"]),
		.executable(name: "VisualizerTestApp", targets: ["VisualizerTestApp"]),
		.executable(name: "Solutions2015", targets: ["Solutions2015"]),
		.executable(name: "Solutions2016", targets: ["Solutions2016"]),
		.executable(name: "Solutions2017", targets: ["Solutions2017"]),
		.executable(name: "Solutions2019", targets: ["Solutions2019"]),
		.executable(name: "Solutions2020", targets: ["Solutions2020"]),
		.executable(name: "Solutions2021", targets: ["Solutions2021"]),
		.executable(name: "Solutions2022", targets: ["Solutions2022"]),
		.executable(name: "Solutions2023", targets: ["Solutions2023"]),
		.executable(name: "Solutions2024", targets: ["Solutions2024"]),
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
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
			]
		),
		.executableTarget(
			name: "VisualizerTestApp",
			dependencies: [
				"Tools"
			]
		),
		.executableTarget(
			name: "Examples",
			dependencies: [
				"Tools"
			],
			resources: [
				.copy("Input"),
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
				.copy("../../Assets/2015"),
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
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
				.copy("../../Assets/2016"),
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
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
				.copy("../../Assets/2017"),
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
			]
		),
		.executableTarget(
			name: "Solutions2018",
			dependencies: [
				"Tools",
				.product(name: "Collections", package: "swift-collections"),
			],
			path: "Sources/Solutions/2018",
			resources: [
				.copy("../../Assets/2018"),
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
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
				.copy("../../Assets/2019"),
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
			]
		),
		.executableTarget(
			name: "Solutions2020",
			dependencies: [
				"Tools",
			],
			path: "Sources/Solutions/2020",
			resources: [
				.copy("../../Assets/2020"),
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
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
				.copy("../../Assets/2021"),
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
			]
		),
		.executableTarget(
			name: "Solutions2022",
			dependencies: [
				"Tools",
			],
			path: "Sources/Solutions/2022",
			resources: [
				.copy("../../Assets/2022"),
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
			]
		),
		.executableTarget(
			name: "Solutions2023",
			dependencies: [
				"Tools"
			],
			path: "Sources/Solutions/2023",
			resources: [
				.copy("../../Assets/2023"),
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
			]
		),
		.executableTarget(
			name: "Solutions2024",
			dependencies: [
				"Tools"
			],
			path: "Sources/Solutions/2024",
			resources: [
				.copy("../../Assets/2024"),
			],
			swiftSettings: [
				.define("Ounchecked", .when(configuration: .release)),
				.define("SWIFT_DISABLE_SAFETY_CHECKS", .when(configuration: .release)),
			]
		),
	]
)
