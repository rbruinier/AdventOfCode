import Foundation
import Tools

final class Day18Solver: DaySolver {
	let dayNumber: Int = 18

	private var input: Input!

	private typealias Grid = Grid2D<Tile>

	private struct Input {
		let grid: Grid
	}

	private enum Tile: String, Hashable, CustomStringConvertible {
		case open = "."
		case trees = "|"
		case lumberyard = "#"

		var description: String {
			rawValue
		}
	}

	private func updateGrid(_ grid: Grid) -> Grid {
		var newTiles = grid.tiles

		for y in 0 ..< grid.dimensions.height {
			for x in 0 ..< grid.dimensions.width {
				var numberOfOpen = 0
				var numberOfTrees = 0
				var numberOfLumberyards = 0

				for sampleY in y - 1 ... y + 1 {
					for sampleX in x - 1 ... x + 1 where !(sampleY == y && sampleX == x) {
						guard
							(0 ..< grid.dimensions.width).contains(sampleX),
							(0 ..< grid.dimensions.height).contains(sampleY)
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

		return .init(tiles: newTiles, dimensions: grid.dimensions)
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
		input = .init(grid: rawString.parseGrid2D())
	}
}
