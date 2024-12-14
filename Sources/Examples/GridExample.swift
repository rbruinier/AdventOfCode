import Foundation
import Tools

final class GridExample: DaySolver {
	let dayNumber: Int = 0

	var customFilename: String? {
		"GridExample"
	}
	
	private typealias Grid = Grid2D<Tile>

	struct Input {
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

	func solvePart1(withInput input: Input) -> Int {
//		let grid = input.grid
//
//		print("Automatic grid debug logging:")
//		print(grid.description)
		
		return 0
	}

	func solvePart2(withInput input: Input) -> Int {
		return 0
	}

	func parseInput(rawString: String) -> Input {
		return .init(grid: rawString.parseGrid2D())
	}
}
