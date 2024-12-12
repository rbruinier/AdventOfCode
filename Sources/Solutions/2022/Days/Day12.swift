import Collections
import Foundation
import Tools

final class Day12Solver: DaySolver {
	let dayNumber: Int = 12

	private var input: Input!

	private struct Input {
		let start: Point2D
		let end: Point2D

		var heightMap: [Point2D: Int]
	}

	private struct GridWrapper: Tools.BFSGrid {
		let heightMap: [Point2D: Int]

		func reachableNeighborsAt(position: Point2D) -> [Point2D] {
			let currentHeight = heightMap[position]!

			return position.neighbors().filter { point in
				guard let neighborHeight = heightMap[point], neighborHeight <= currentHeight + 1 else {
					return false
				}

				return true
			}
		}
	}

	init() {}

	func solvePart1() -> Int {
		let bfsGrid = GridWrapper(heightMap: input.heightMap)

		return BFS.shortestPathInGrid(bfsGrid, from: input.start, to: input.end)!.steps
	}

	func solvePart2() -> Int {
		let bfsGrid = GridWrapper(heightMap: input.heightMap)

		let allZeroHeightPoints = input.heightMap.filter { $0.value == 0 }

		var minimumSteps = Int.max
		for startPoint in allZeroHeightPoints.keys {
			if let steps = BFS.shortestPathInGrid(bfsGrid, from: startPoint, to: input.end)?.steps {
				minimumSteps = min(minimumSteps, steps)
			}
		}

		return minimumSteps
	}

	func parseInput(rawString: String) {
		var start: Point2D = .zero
		var end: Point2D = .zero

		var heightMap: [Point2D: Int] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, value) in line.enumerated() {
				let point = Point2D(x: x, y: y)
				switch String(value) {
				case "S":
					start = point
					heightMap[point] = 0
				case "E":
					end = point
					heightMap[point] = 25
				default:
					heightMap[point] = Int(value.asciiValue! - AsciiCharacter.a)
				}
			}
		}

		input = .init(start: start, end: end, heightMap: heightMap)
	}
}
