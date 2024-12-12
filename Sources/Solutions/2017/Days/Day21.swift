import Foundation
import Tools

/// Part 2 is optimized by reducing all tiles back to 3x3 groups of tiles because the cycle is 3, 2, 2 for every 3 iterations. This saves a lot of effort in maintaining
/// huge sets.
final class Day21Solver: DaySolver {
	let dayNumber: Int = 21

	private var input: Input!

	private struct Input {
		let tiles: Set<Point2D>
		let sizeTwoMappings: [Int: Set<Point2D>]
		let sizeThreeMappings: [Int: Set<Point2D>]
	}

	private struct Mapping {
		let input: Set<Point2D>
		let output: Set<Point2D>
	}

	private func solve(tiles: [Point2D], iterations: Int) -> [Point2D] {
		var tiles = tiles

		var size = 3
		for _ in 0 ..< iterations {
			var newTiles: [Point2D] = []

			newTiles.reserveCapacity(10_000_000)

			if size % 2 == 0 {
				let groupSize = 2
				let loopSize = size / groupSize

				for groupY in 0 ..< loopSize {
					let minY = groupY * groupSize
					let maxY = minY + groupSize

					for groupX in 0 ..< loopSize {
						let minX = groupX * groupSize
						let maxX = minX + groupSize

						let translatedPoints: Set<Point2D> = Set(tiles.filter { point in
							(minX ..< maxX).contains(point.x) && (minY ..< maxY).contains(point.y)
						}.map { point in
							Point2D(x: point.x - minX, y: point.y - minY)
						})

						guard let output = input.sizeTwoMappings[translatedPoints.hashValue] else {
							fatalError()
						}

						for point in output {
							newTiles.append(Point2D(x: groupX * 3 + point.x, y: groupY * 3 + point.y))
						}
					}
				}

				size = (size / 2) * 3
			} else {
				let groupSize = 3
				let loopSize = size / groupSize

				for groupY in 0 ..< loopSize {
					let minY = groupY * groupSize
					let maxY = minY + groupSize

					let yRange = minY ..< maxY

					for groupX in 0 ..< loopSize {
						let minX = groupX * groupSize
						let maxX = minX + groupSize

						let translatedPoints: Set<Point2D> = Set(tiles.filter { point in
							(minX ..< maxX).contains(point.x) && yRange.contains(point.y)
						}.map { point in
							Point2D(x: point.x - minX, y: point.y - minY)
						})

						guard let output = input.sizeThreeMappings[translatedPoints.hashValue] else {
							fatalError()
						}

						for point in output {
							newTiles.append(Point2D(x: groupX * 4 + point.x, y: groupY * 4 + point.y))
						}
					}
				}

				size = (size / 3) * 4
			}

			tiles = newTiles
		}

		return tiles
	}

	func solvePart1() -> Int {
		solve(tiles: Array(input.tiles), iterations: 5).count
	}

	func solvePart2() -> Int {
		// cycle of 3 is always 3, 2, 2 so we make little groups again after 3 cycles so our sets stay small
		let cycleSize = 3

		var groups: [[Point2D]] = [Array(input.tiles)]

		for _ in 0 ..< (18 / cycleSize) {
			var newGroups: [[Point2D]] = []

			for group in groups {
				let newTiles = solve(tiles: Array(group), iterations: cycleSize)

				// split in 3 x 3 groups of 3 x 3 tiles

				let groupSize = 3
				let loopSize = 3

				for groupY in 0 ..< loopSize {
					let minY = groupY * groupSize
					let maxY = minY + groupSize

					for groupX in 0 ..< loopSize {
						let minX = groupX * groupSize
						let maxX = minX + groupSize

						let translatedPoints: Set<Point2D> = Set(newTiles.filter { point in
							(minX ..< maxX).contains(point.x) && (minY ..< maxY).contains(point.y)
						}.map { point in
							Point2D(x: point.x - minX, y: point.y - minY)
						})

						var newGroupTiles: [Point2D] = []

						for point in translatedPoints {
							newGroupTiles.append(Point2D(x: point.x, y: point.y))
						}

						newGroups.append(newGroupTiles)
					}
				}
			}

			groups = newGroups
		}

		return groups.reduce(0) { $0 + $1.count }
	}

	func parseInput(rawString: String) {
		let tiles: Set<Point2D> = [
			.init(x: 1, y: 0),
			.init(x: 2, y: 1),
			.init(x: 0, y: 2),
			.init(x: 1, y: 2),
			.init(x: 2, y: 2),
		]

		var sizeTwoMappings: [Mapping] = []
		var sizeThreeMappings: [Mapping] = []

		func flipPatternVertically(_ input: Set<Point2D>, size: Int) -> Set<Point2D> {
			Set(input.map { Point2D(x: $0.x, y: size - 1 - $0.y) })
		}

		func flipPatternHorizontally(_ input: Set<Point2D>, size: Int) -> Set<Point2D> {
			Set(input.map { Point2D(x: size - 1 - $0.x, y: $0.y) })
		}

		func rotatePattern(_ input: Set<Point2D>, size: Int, degrees: Point2D.Degrees) -> Set<Point2D> {
			Set(input.map { point in
				switch degrees {
				case .zero,
				     .threeSixty:
					point
				case .ninety:
					point.turned(degrees: .ninety) + .init(x: 0, y: size - 1)
				case .oneEighty:
					point.turned(degrees: .oneEighty) + .init(x: size - 1, y: size - 1)
				case .twoSeventy:
					point.turned(degrees: .twoSeventy) + .init(x: size - 1, y: 0)
				}
			})
		}

		let rotations: [Point2D.Degrees] = [.zero, .ninety, .oneEighty, .twoSeventy]

		for (index, line) in rawString.allLines().enumerated() {
			let parts = line.components(separatedBy: " => ")

			let inputComponents = parts[0].components(separatedBy: "/")
			let outputComponents = parts[1].components(separatedBy: "/")

			var inputPoints: Set<Point2D> = []
			var outputPoints: Set<Point2D> = []

			if index < 6 {
				for y in 0 ..< 2 {
					for x in 0 ..< 2 {
						if inputComponents[y][x] == "#" {
							inputPoints.insert(.init(x: x, y: y))
						}
					}
				}

				for y in 0 ..< 3 {
					for x in 0 ..< 3 {
						if outputComponents[y][x] == "#" {
							outputPoints.insert(.init(x: x, y: y))
						}
					}
				}

				for rotation in rotations {
					let rotatedPoints = rotatePattern(inputPoints, size: 2, degrees: rotation)

					sizeTwoMappings.append(.init(input: rotatedPoints, output: outputPoints))
					sizeTwoMappings.append(.init(input: flipPatternVertically(rotatedPoints, size: 2), output: outputPoints))
					sizeTwoMappings.append(.init(input: flipPatternHorizontally(rotatedPoints, size: 2), output: outputPoints))
				}
			} else {
				for y in 0 ..< 3 {
					for x in 0 ..< 3 {
						if inputComponents[y][x] == "#" {
							inputPoints.insert(.init(x: x, y: y))
						}
					}
				}

				for y in 0 ..< 4 {
					for x in 0 ..< 4 {
						if outputComponents[y][x] == "#" {
							outputPoints.insert(.init(x: x, y: y))
						}
					}
				}

				for rotation in rotations {
					let rotatedPoints = rotatePattern(inputPoints, size: 3, degrees: rotation)

					sizeThreeMappings.append(.init(input: rotatedPoints, output: outputPoints))
					sizeThreeMappings.append(.init(input: flipPatternHorizontally(rotatedPoints, size: 3), output: outputPoints))
					sizeThreeMappings.append(.init(input: flipPatternVertically(rotatedPoints, size: 3), output: outputPoints))
				}
			}
		}

		var sizeTwoMappingsAsDictionary: [Int: Set<Point2D>] = [:]
		var sizeThreeMappingsAsDictionary: [Int: Set<Point2D>] = [:]

		for mapping in sizeTwoMappings {
			sizeTwoMappingsAsDictionary[mapping.input.hashValue] = mapping.output
		}

		for mapping in sizeThreeMappings {
			sizeThreeMappingsAsDictionary[mapping.input.hashValue] = mapping.output
		}

		input = .init(tiles: tiles, sizeTwoMappings: sizeTwoMappingsAsDictionary, sizeThreeMappings: sizeThreeMappingsAsDictionary)
	}
}
