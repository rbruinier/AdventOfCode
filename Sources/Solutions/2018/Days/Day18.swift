import Foundation
import Tools

final class Day18Solver: DaySolver {
	let dayNumber: Int = 18

	let expectedPart1Result = 519552
	let expectedPart2Result = 165376

	private var input: Input!

	private struct Input {
		let grid: Grid
	}

	private struct Grid: Hashable, CustomStringConvertible {
		let tiles: [[Tile]]
		let size: Size

		var description: String {
			var line = ""

			for y in 0 ..< size.height {
				for x in 0 ..< size.width {
					line += tiles[y][x].description
				}

				line += "\n"
			}

			return line
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(tiles)
		}
	}

	private enum Tile: Hashable, CustomStringConvertible {
		case open
		case trees
		case lumberyard

		var description: String {
			switch self {
			case .open: "."
			case .trees: "|"
			case .lumberyard: "#"
			}
		}
	}

	private func updateGrid(_ grid: Grid) -> Grid {
		var newTiles = grid.tiles

		for y in 0 ..< grid.size.height {
			for x in 0 ..< grid.size.width {
				var numberOfOpen = 0
				var numberOfTrees = 0
				var numberOfLumberyards = 0

				for sampleY in y - 1 ... y + 1 {
					for sampleX in x - 1 ... x + 1 where !(sampleY == y && sampleX == x) {
						guard
							(0 ..< grid.size.width).contains(sampleX),
							(0 ..< grid.size.height).contains(sampleY)
						else {
							continue
						}

						switch grid.tiles[sampleY][sampleX] {
						case .open: numberOfOpen += 1
						case .trees: numberOfTrees += 1
						case .lumberyard: numberOfLumberyards += 1
						}
					}
				}

				switch grid.tiles[y][x] {
				case .open:
					newTiles[y][x] = numberOfTrees >= 3 ? .trees : .open
				case .trees:
					newTiles[y][x] = numberOfLumberyards >= 3 ? .lumberyard : .trees
				case .lumberyard:
					newTiles[y][x] = (numberOfTrees >= 1 && numberOfLumberyards >= 1) ? .lumberyard : .open
				}
			}
		}

		return .init(tiles: newTiles, size: grid.size)
	}

	func solvePart1() -> Int {
		var grid = input.grid

		for _ in 0 ..< 10 {
			grid = updateGrid(grid)
		}

		let tiles = grid.tiles.flatMap { $0 }

		let numberOfTrees = tiles.filter { $0 == .trees }.count
		let numberOfLumberyards = tiles.filter { $0 == .lumberyard }.count

		return numberOfTrees * numberOfLumberyards
	}

	func solvePart2() -> Int {
		var grid = input.grid

		var states: [Int: Int] = [:]
		var grids: [Int: Grid] = [:]

		let numberOfRounds = 1_000_000_000

		// cycle detection
		for minute in 0 ..< numberOfRounds {
			if let repeatingIndex = states[grid.hashValue] {
				let currentIndex = minute

				let cycleSize = currentIndex - repeatingIndex

				let remainingCycles = numberOfRounds - currentIndex
				let modded = remainingCycles % cycleSize

				let minuteIndex = repeatingIndex + modded

				let tiles = grids[minuteIndex]!.tiles.flatMap { $0 }

				let numberOfTrees = tiles.filter { $0 == .trees }.count
				let numberOfLumberyards = tiles.filter { $0 == .lumberyard }.count

				return numberOfTrees * numberOfLumberyards
			}

			states[grid.hashValue] = minute
			grids[minute] = grid

			grid = updateGrid(grid)
		}

		preconditionFailure()
	}

	func parseInput(rawString: String) {
		let tiles: [Point2D: Tile] = rawString.parseGrid { char, _ in
			switch char {
			case ".": .open
			case "|": .trees
			case "#": .lumberyard
			default: preconditionFailure()
			}
		}

		let size = Size(
			width: tiles.keys.map(\.x).max()! + 1,
			height: tiles.keys.map(\.y).max()! + 1
		)

		var gridTiles: [[Tile]] = .init(repeating: .init(repeating: .open, count: size.width), count: size.height)

		for (point, tile) in tiles {
			gridTiles[point.y][point.x] = tile
		}

		input = .init(grid: .init(tiles: gridTiles, size: size))
	}
}
