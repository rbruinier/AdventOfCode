import Foundation
import Tools

final class Day06Solver: DaySolver {
	let dayNumber: Int = 6

	enum Tile: String, CustomStringConvertible {
		case empty = "."
		case obstacle = "#"

		var description: String { rawValue }
	}

	struct Input: Sendable {
		let map: Grid2D<Tile>
		let startPosition: Point2D
	}

	func getPath(map: [[Tile]], startPosition: Point2D) -> Set<Point2D> {
		var position = startPosition
		var direction = Direction.north

		var visited: Set<Point2D> = []

		while map[safe: position.y]?[safe: position.x] != nil {
			visited.insert(position)

			let newPosition = position.moved(to: direction)

			if map[safe: newPosition.y]?[safe: newPosition.x] == .obstacle {
				direction = direction.turned(degrees: .ninety)
			} else {
				position = newPosition
			}
		}

		return visited
	}

	private static func isLooping(map: Grid2D<Tile>, startPosition: Point2D) async -> Bool {
		var position = startPosition
		var direction = Direction.north

		struct Visited: Hashable {
			let position: Point2D
			let direction: Direction
		}

		var path: Set<Visited> = .init(minimumCapacity: 8000)

		while map.isSafe(position: position) {
			let visited = Visited(position: position, direction: direction)

			if path.contains(visited) {
				return true
			}

			path.insert(Visited(position: position, direction: direction))

			let newPosition = position.moved(to: direction)

			if map.isSafe(position: newPosition), map.tiles[newPosition.y][newPosition.x] == .obstacle {
				direction = direction.turned(degrees: .ninety)
			} else {
				position = newPosition
			}
		}

		// in case we get out of the map we are not stuck in a loop
		return false
	}

	func solvePart1(withInput input: Input) -> Int {
		getPath(map: input.map.tiles, startPosition: input.startPosition).count
	}

	func solvePart2(withInput input: Input) async -> Int {
		let originalMap = input.map
		let startPosition = input.startPosition

		let originalPath = getPath(map: originalMap.tiles, startPosition: startPosition)

		let pointsToTest = originalPath.subtracting([startPosition])

		return await withTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
			for point in pointsToTest {
				taskGroup.addTask {
					var newMap = originalMap

					newMap.tiles[point.y][point.x] = .obstacle

					return await Self.isLooping(map: newMap, startPosition: startPosition) ? 1 : 0
				}
			}

			return await taskGroup.reduce(into: 0) { $0 += $1 }
		}
	}

	func parseInput(rawString: String) -> Input {
		var startPosition: Point2D = .zero

		let map: Grid2D<Tile> = rawString.parseGrid2D { character, position in
			switch character {
			case ".": return .empty
			case "#": return .obstacle
			case "^":
				startPosition = position
				return .empty
			default:
				preconditionFailure()
			}
		}

		return .init(map: map, startPosition: startPosition)
	}
}
