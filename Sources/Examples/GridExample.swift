import Foundation
import Tools

final class GridExample: DaySolver {
	let dayNumber: Int = 0

	var customFilename: String? {
		"GridExample"
	}
	
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

	func solvePart1() -> Int {
//		let grid = input.grid
//
//		print("Automatic grid debug logging:")
//		print(grid.description)
		
		return 0
	}

	func solvePart2() -> Int {
		return 0
	}

	func parseInput(rawString: String) {
		input = .init(grid: rawString.parseGrid2D())
	}
}
