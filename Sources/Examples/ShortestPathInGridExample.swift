import Foundation
import Tools

final class ShortestPathInGridExample: DaySolver {
	let dayNumber: Int = 0

	var customFilename: String? {
		"ShortestPathInGridExample"
	}

	private typealias Grid = Grid2D<Tile>

	struct Input {
		let grid: Grid
	}

	private struct GridWrapper: Tools.BFSGrid {
		let grid: Grid

		func reachableNeighborsAt(position: Point2D) -> [Point2D] {
			guard case .land(let currentHeight) = grid[position] else {
				return []
			}

			return position.neighbors().filter { point in
				guard
					case .land(let neighborHeight) = grid[safe: point],
					neighborHeight <= currentHeight + 1
				else {
					return false
				}

				return true
			}
		}
	}

	private enum Tile: Hashable, CustomStringConvertible {
		case start
		case end
		case land(height: Int)

		var description: String {
			switch self {
			case .start: "S"
			case .end: "E"
			case .land(let height):
				String(bytes: [UInt8(height) + AsciiCharacter.a], encoding: .ascii)!
			}
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		var grid = input.grid

		var startPoint: Point2D!
		var endPoint: Point2D!

		for y in 0 ..< grid.dimensions.height {
			for x in 0 ..< grid.dimensions.width {
				switch grid.tiles[y][x] {
				case .start: startPoint = Point2D(x: x, y: y)
				case .end: endPoint = Point2D(x: x, y: y)
				default: break
				}
			}
		}

		grid.tiles[startPoint.y][startPoint.x] = .land(height: 0)
		grid.tiles[endPoint.y][endPoint.x] = .land(height: 25)

		let shortestPath = BFS.shortestPathInGrid(GridWrapper(grid: grid), from: startPoint, to: endPoint)!

		return shortestPath.steps
	}

	func solvePart2(withInput input: Input) -> Int {
		0
	}

	func parseInput(rawString: String) -> Input {
		return .init(grid: rawString.parseGrid2D { character, _ in
			switch character {
			case "S": .start
			case "E": .end
			default: .land(height: Int(character[character.startIndex].asciiValue! - AsciiCharacter.a))
			}
		})
	}
}
