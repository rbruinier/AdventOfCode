import Collections
import Foundation
import Tools

final class Day16Solver: DaySolver {
	let dayNumber: Int = 16

	typealias Tiles = [Point2D: Tile]

	struct Input {
		let tiles: Tiles
	}

	enum Tile {
		case backslash
		case slash
		case verticalSplitter
		case horizontalSplitter
	}

	private func solveBeamPath(withTiles tiles: Tiles, startPoint: Point2D, direction: Direction) -> Set<Point2D> {
		let maxX = tiles.keys.map(\.x).max()!
		let maxY = tiles.keys.map(\.y).max()!

		struct Item: Hashable {
			let point: Point2D
			let direction: Direction
		}

		var items: Deque<Item> = [.init(point: startPoint, direction: direction)]
		var path: Set<Point2D> = []

		// if we are at the same point in the same direction we should not further process this queue item
		var visitedItems: Set<Item> = []

		itemLoop: while let item = items.popFirst() {
			guard !visitedItems.contains(item) else {
				continue
			}

			visitedItems.insert(item)

			var newDirection = item.direction
			var point = item.point

			// continue till we branch or run out of valid grid area
			while true {
				point = point.moved(to: newDirection)

				// out of range, stop
				if !(0 ... maxX).contains(point.x) || !(0 ... maxY).contains(point.y) {
					continue itemLoop
				}

				path.insert(point)

				switch tiles[point] {
				case nil: break
				case .backslash:
					switch newDirection {
					case .east: newDirection = .south
					case .west: newDirection = .north
					case .south: newDirection = .east
					case .north: newDirection = .west
					default: preconditionFailure()
					}
				case .slash:
					switch newDirection {
					case .east: newDirection = .north
					case .west: newDirection = .south
					case .south: newDirection = .west
					case .north: newDirection = .east
					default: preconditionFailure()
					}
				case .verticalSplitter:
					switch newDirection {
					case .east,
					     .west:
						items.append(.init(point: point, direction: .north))
						items.append(.init(point: point, direction: .south))

						continue itemLoop
					case .north,
					     .south:
						break
					default: preconditionFailure()
					}
				case .horizontalSplitter:
					switch newDirection {
					case .north,
					     .south:
						items.append(.init(point: point, direction: .east))
						items.append(.init(point: point, direction: .west))

						continue itemLoop
					case .east,
					     .west:
						break
					default: preconditionFailure()
					}
				}
			}
		}

		return path
	}

	func solvePart1(withInput input: Input) -> Int {
		solveBeamPath(withTiles: input.tiles, startPoint: .init(x: -1, y: 0), direction: .east).count
	}

	func solvePart2(withInput input: Input) -> Int {
		let maxX = input.tiles.keys.map(\.x).max()!
		let maxY = input.tiles.keys.map(\.y).max()!

		var maxCount = Int.min

		for y in 0 ... maxY {
			maxCount = max(maxCount, solveBeamPath(withTiles: input.tiles, startPoint: .init(x: -1, y: y), direction: .east).count)
			maxCount = max(maxCount, solveBeamPath(withTiles: input.tiles, startPoint: .init(x: maxX + 1, y: y), direction: .west).count)
		}

		for x in 0 ... maxX {
			maxCount = max(maxCount, solveBeamPath(withTiles: input.tiles, startPoint: .init(x: x, y: -1), direction: .south).count)
			maxCount = max(maxCount, solveBeamPath(withTiles: input.tiles, startPoint: .init(x: x + 1, y: maxY + 1), direction: .north).count)
		}

		return maxCount
	}

	func parseInput(rawString: String) -> Input {
		return .init(tiles: rawString.parseGrid { character, _ in
			switch character {
			case "\\": Tile.backslash
			case "/": Tile.slash
			case "|": Tile.verticalSplitter
			case "-": Tile.horizontalSplitter
			case ".": nil
			default: preconditionFailure()
			}
		})
	}
}
