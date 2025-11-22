import Foundation
import Tools

final class GridExample: DaySolver {
	let dayNumber: Int = 0

	var customFilename: String? {
		"GridExample"
	}

	typealias Grid = Grid2D<Tile>

	struct Input {
		let grid: Grid
	}

	enum Tile: String, Hashable, CustomStringConvertible {
		case open = "."
		case trees = "|"
		case lumberyard = "#"

		var description: String {
			rawValue
		}
	}

	func solvePart1(withInput input: Input) -> Int {
//		let grid = input.grid
//
//		print("Automatic grid debug logging:")
//		print(grid.description)

		0
	}

	func solvePart2(withInput input: Input) -> Int {
		0
	}

	func parseInput(rawString: String) -> Input {
		.init(grid: rawString.parseGrid2D())
	}
}
