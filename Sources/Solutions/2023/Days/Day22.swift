import Foundation
import Tools

final class Day22Solver: DaySolver {
	let dayNumber: Int = 22

	let expectedPart1Result = 405
	let expectedPart2Result = 61297

	private var input: Input!

	private struct Input {
		let bricks: [Brick]
	}

	private enum Orientation {
		case x
		case y
		case z
	}

	private struct Brick: Equatable {
		let a: Point3D
		let b: Point3D

		let id: Int

		var orientation: Orientation {
			if a.x != b.x {
				.x
			} else if a.y != b.y {
				.y
			} else if a.z != b.z {
				.z
			} else {
				.z // it doesn't matter in this case
			}
		}
	}

	private struct Result {
		let bricks: [Brick]

		let supportedBy: [Int: Set<Int>]
		let supporting: [Int: Set<Int>]
	}

	private func simulateBricks(_ originalBricks: [Brick]) -> Result {
		// sort vertically so that we can move them one by one
		let bricks = originalBricks.sorted(by: { $0.a.z < $1.a.z })

		var supportedBy: [Int: Set<Int>] = [:]
		var supporting: [Int: Set<Int>] = [:]

		struct MapItem {
			var id: Int
			var height: Int

			static var ground: MapItem { .init(id: -1, height: 0) }
		}

		var newBricks: [Brick] = []
		var heightMap: [Point2D: MapItem] = [:]

		for brick in bricks {
			let a = brick.a
			let b = brick.b

			switch brick.orientation {
			case .x:
				var bestZOffset = 0

				zOffsetLoop: for zOffset in 1 ... 10000 {
					let height = a.z - zOffset

					for x in a.x ... b.x {
						let point = Point2D(x: x, y: a.y)

						if height <= heightMap[point, default: .ground].height {
							break zOffsetLoop
						}
					}

					bestZOffset = zOffset
				}

				let newZ = a.z - bestZOffset

				newBricks.append(.init(a: .init(x: a.x, y: a.y, z: newZ), b: .init(x: b.x, y: b.y, z: newZ), id: brick.id))

				for x in a.x ... b.x {
					let point = Point2D(x: x, y: a.y)

					if let existingMapItem = heightMap[point], existingMapItem.height == newZ - 1 {
						supportedBy[existingMapItem.id, default: []].insert(brick.id)
						supporting[brick.id, default: []].insert(existingMapItem.id)
					}

					heightMap[point] = .init(id: brick.id, height: newZ)
				}
			case .y:
				var bestZOffset = 0

				zOffsetLoop: for zOffset in 1 ... 10000 {
					let height = a.z - zOffset

					for y in a.y ... b.y {
						let point = Point2D(x: a.x, y: y)

						if height <= heightMap[point, default: .ground].height {
							break zOffsetLoop
						}
					}

					bestZOffset = zOffset
				}

				let newZ = a.z - bestZOffset

				newBricks.append(.init(a: .init(x: a.x, y: a.y, z: newZ), b: .init(x: b.x, y: b.y, z: newZ), id: brick.id))

				for y in a.y ... b.y {
					let point = Point2D(x: a.x, y: y)

					if let existingMapItem = heightMap[point], existingMapItem.height == newZ - 1 {
						supportedBy[existingMapItem.id, default: []].insert(brick.id)
						supporting[brick.id, default: []].insert(existingMapItem.id)
					}

					heightMap[point] = .init(id: brick.id, height: newZ)
				}
			case .z:
				var bestZOffset = 0

				let point = Point2D(x: a.x, y: a.y)

				zOffsetLoop: for zOffset in 1 ... 10000 {
					let height = a.z - zOffset

					if height <= heightMap[point, default: .ground].height {
						break zOffsetLoop
					}

					bestZOffset = zOffset
				}

				let newZ = a.z - bestZOffset

				newBricks.append(.init(a: .init(x: a.x, y: a.y, z: newZ), b: .init(x: b.x, y: b.y, z: b.z - bestZOffset), id: brick.id))

				if let existingMapItem = heightMap[point], existingMapItem.height == newZ - 1 {
					supportedBy[existingMapItem.id, default: []].insert(brick.id)
					supporting[brick.id, default: []].insert(existingMapItem.id)
				}

				heightMap[point] = .init(id: brick.id, height: b.z - bestZOffset)
			}
		}

		return .init(bricks: newBricks, supportedBy: supportedBy, supporting: supporting)
	}

	/*
	 Observations:
	  * there are no bricks that expand in more than 1 direction.
	  * a.z is always < b.z
	 */
	func solvePart1() -> Int {
		let result = simulateBricks(input.bricks)

		var bricksThatCanBeRemoved: Set<Int> = []

		for brick in input.bricks {
			let brickSupports = result.supportedBy[brick.id, default: []]

			if brickSupports.isEmpty {
				bricksThatCanBeRemoved.insert(brick.id)

				continue
			}

			if brickSupports.filter({ result.supporting[$0]!.count > 1 }).count == brickSupports.count {
				bricksThatCanBeRemoved.insert(brick.id)
			}
		}

		return bricksThatCanBeRemoved.count
	}

	func solvePart2() -> Int {
		let result = simulateBricks(input.bricks)

		// brute force removing each
		var changedCounter = 0

		for (index, brick) in result.bricks.enumerated() {
			var beforeBricks = result.bricks

			beforeBricks.remove(at: index)

			let afterBricks = simulateBricks(beforeBricks).bricks

			for brickID in beforeBricks.map(\.id) {
				let beforeBrick = beforeBricks.first { $0.id == brickID }!
				let afterBrick = afterBricks.first { $0.id == brickID }!

				if beforeBrick != afterBrick {
					changedCounter += 1
				}
			}
		}

		return changedCounter
	}

	func parseInput(rawString: String) {
		input = .init(bricks: rawString.allLines().enumerated().map { line in
			let components = line.element.components(separatedBy: "~")

			let a = Point3D(commaSeparatedString: components[0])
			let b = Point3D(commaSeparatedString: components[1])

			return Brick(
				a: a,
				b: b,
				id: line.offset
			)
		})
	}
}
