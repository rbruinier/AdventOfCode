import Foundation
import Tools

final class Day22Solver: DaySolver {
	let dayNumber: Int = 22

	private var input: Input!

	private struct Input {
		let bricks: [Brick]
	}

	private enum Orientation {
		case x
		case y
		case z
	}

	private struct Brick {
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

		let movedBricksCounter: Int
	}

	private func simulateBricks(_ originalBricks: [Brick], generateDependencyGraph: Bool) -> Result {
		// sort vertically so that we can move them one by one
		let bricks = originalBricks.sorted(by: { $0.a.z < $1.a.z })

		var supportedBy: [Int: Set<Int>] = [:]
		var supporting: [Int: Set<Int>] = [:]

		struct MapItem {
			var id: Int
			var height: Int

			static var ground: MapItem { .init(id: -1, height: 0) }
		}

		var newBricks: [Brick] = .init(reservedCapacity: originalBricks.count)
		var movedBricksCounter = 0

		var heightMap: [Point2D: MapItem] = [:]

		for brick in bricks {
			let a = brick.a
			let b = brick.b

			let mapCoordinates: [Point2D]

			switch brick.orientation {
			case .x: mapCoordinates = (a.x ... b.x).map { Point2D(x: $0, y: a.y) }
			case .y: mapCoordinates = (a.y ... b.y).map { Point2D(x: a.x, y: $0) }
			case .z: mapCoordinates = [Point2D(x: a.x, y: a.y)]
			}

			var highestHeight = 0
			for coordinate in mapCoordinates {
				if let existingMapItem = heightMap[coordinate] {
					highestHeight = max(highestHeight, existingMapItem.height)
				}
			}

			let newA = Point3D(x: a.x, y: a.y, z: highestHeight + 1)
			let newB = Point3D(x: b.x, y: b.y, z: highestHeight + 1 + (b.z - a.z))

			for coordinate in mapCoordinates {
				if generateDependencyGraph, let existingMapItem = heightMap[coordinate], existingMapItem.height == highestHeight {
					supportedBy[existingMapItem.id, default: []].insert(brick.id)
					supporting[brick.id, default: []].insert(existingMapItem.id)
				}

				heightMap[coordinate] = .init(id: brick.id, height: newB.z)
			}

			newBricks.append(Brick(a: newA, b: newB, id: brick.id))

			if newA.z != a.z {
				movedBricksCounter += 1
			}
		}

		return .init(bricks: newBricks, supportedBy: supportedBy, supporting: supporting, movedBricksCounter: movedBricksCounter)
	}

	/*
	 Observations:
	  * there are no bricks that expand in more than 1 direction.
	  * a.z is always <= b.z
	 */
	func solvePart1() -> Int {
		let result = simulateBricks(input.bricks, generateDependencyGraph: true)

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
		let result = simulateBricks(input.bricks, generateDependencyGraph: false)

		// brute force removing each
		var changedCounter = 0

		for index in 0 ..< result.bricks.count {
			var beforeBricks = result.bricks

			beforeBricks.remove(at: index)

			changedCounter += simulateBricks(beforeBricks, generateDependencyGraph: false).movedBricksCounter
		}

		return changedCounter
	}

	func parseInput(rawString: String) {
		input = .init(bricks: rawString.allLines().enumerated().map { line in
			let components = line.element.components(separatedBy: "~")

			return Brick(
				a: Point3D(commaSeparatedString: components[0]),
				b: Point3D(commaSeparatedString: components[1]),
				id: line.offset
			)
		})
	}
}
