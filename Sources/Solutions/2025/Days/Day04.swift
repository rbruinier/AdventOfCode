import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	private var input: Input!

	enum Tile: String, Hashable, CustomStringConvertible {
		case empty = "."
		case roll = "@"

		var description: String {
			rawValue
		}
	}

	typealias Grid = Grid2D<Tile>

	struct Input {
		let grid: Grid
	}

	private func removeRolls(in grid: Grid) -> (count: Int, newGrid: Grid) {
		var newGrid = grid
		var sum = 0

		for y in 0 ..< grid.dimensions.height {
			for x in 0 ..< grid.dimensions.width {
				let position = Point2D(x: x, y: y)

				guard grid[position] == .roll else {
					continue
				}

				let nrOfRolls = grid
					.safeNeighbors(at: position, includingDiagonals: true)
					.count(where: { grid[$0] == .roll })

				if nrOfRolls < 4 {
					newGrid[position] = .empty

					sum += 1
				}
			}
		}

		return (count: sum, newGrid: newGrid)
	}

	func solvePart1(withInput input: Input) -> Int {
		removeRolls(in: input.grid).count
	}

	func solvePart2(withInput input: Input) -> Int {
		var grid = input.grid

		var sum = 0

		while true {
			let (count, newGrid) = removeRolls(in: grid)

			if count == 0 {
				break
			}

			sum += count

			grid = newGrid
		}

		return sum
	}

	func parseInput(rawString: String) -> Input {
		.init(grid: rawString.parseGrid2D())
	}
}
