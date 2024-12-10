import Collections
import Foundation
import Tools

final class Day10Solver: DaySolver {
	let dayNumber: Int = 10

	let expectedPart1Result = 652
	let expectedPart2Result = 1432

	private var input: Input!

	private struct Input {
		var heightmap: [Point2D: Int]
	}

	private static func trailheads(in heightmap: [Point2D: Int]) -> Set<Point2D> {
		Set(heightmap.filter { $0.value == 0 }.map(\.key))
	}

	private static func pathsFrom(_ startingPoint: Point2D, in heightmap: [Point2D: Int]) -> [[Point2D]] {
		struct Path {
			let path: [Point2D]
			let currentHeight: Int
		}

		var stack: Deque<Path> = [.init(path: [startingPoint], currentHeight: 0)]

		var paths: [Path] = []

		// BFS
		while let path = stack.popFirst() {
			if path.currentHeight == 9 {
				paths.append(path)

				continue
			}

			let position = path.path.last!

			for neighbor in position.neighbors() {
				guard let height = heightmap[neighbor], height == path.currentHeight + 1, !path.path.contains(neighbor) else {
					continue
				}

				stack.append(.init(path: path.path + [neighbor], currentHeight: path.currentHeight + 1))
			}
		}

		return paths.map(\.path)
	}

	func solvePart1() async -> Int {
		let heightmap = input.heightmap

		let trailheads = Self.trailheads(in: heightmap)

		return await withTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
			for trailhead in trailheads {
				taskGroup.addTask {
					let paths = Self.pathsFrom(trailhead, in: heightmap)

					return Set(paths.map { $0.last! }).count
				}
			}

			return await taskGroup.reduce(into: 0) { $0 += $1 }
		}
	}

	func solvePart2() async -> Int {
		let heightmap = input.heightmap

		let trailheads = Self.trailheads(in: heightmap)

		return await withTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
			for trailhead in trailheads {
				taskGroup.addTask {
					let paths = Self.pathsFrom(trailhead, in: heightmap)

					return paths.count
				}
			}

			return await taskGroup.reduce(into: 0) { $0 += $1 }
		}
	}

	func parseInput(rawString: String) {
		var heightmap: [Point2D: Int] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, character) in line.enumerated() {
				heightmap[.init(x: x, y: y)] = Int(String(character))
			}
		}

		input = .init(heightmap: heightmap)
	}
}
