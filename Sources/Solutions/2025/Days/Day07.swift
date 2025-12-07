import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	private var input: Input!

	enum Tile: String, Hashable, CustomStringConvertible {
		case empty = "."
		case splitter = "^"
		case start = "S"

		var description: String {
			rawValue
		}
	}

	typealias Grid = Grid2D<Tile>

	struct Input {
		let grid: Grid
	}

	private func solveBeam(from position: Point2D, grid: Grid, memoization: inout [Int: Int]) -> Int {
		let hash = position.hashValue

		if let result = memoization[hash] {
			return result
		}

		let south = position.moved(to: .south)

		if south.y >= grid.dimensions.height {
			return 1
		}

		if [Tile.start, Tile.empty].contains(grid[south]) {
			let result = solveBeam(from: south, grid: grid, memoization: &memoization)

			memoization[hash] = result

			return result
		}

		let left = south.moved(to: .west)
		let right = south.moved(to: .east)

		var lhs = 0
		var rhs = 0

		if grid.isSafe(position: left) {
			lhs = solveBeam(from: left, grid: grid, memoization: &memoization)
		}

		if grid.isSafe(position: right) {
			rhs = solveBeam(from: right, grid: grid, memoization: &memoization)
		}

		memoization[hash] = lhs + rhs

		return lhs + rhs
	}

	func solvePart1(withInput input: Input) -> Int {
		let grid = input.grid

		guard let startPosition = grid.findFirst(tile: .start) else {
			preconditionFailure()
		}

		var activeBeams: Set<Int> = [startPosition.x]

		var splitCount = 0

		for y in 1 ..< grid.dimensions.height {
			var newActiveBeams: Set<Int> = []

			for x in activeBeams {
				switch grid[y, x] {
				case .empty:
					newActiveBeams.insert(x)
				case .splitter:
					splitCount += 1

					if grid.isSafe(position: Point2D(x: x - 1, y: y)) {
						newActiveBeams.insert(x - 1)
					}

					if grid.isSafe(position: Point2D(x: x + 1, y: y)) {
						newActiveBeams.insert(x + 1)
					}
				case .start:
					break
				}
			}

			activeBeams = newActiveBeams
		}

		return splitCount
	}

	func solvePart2(withInput input: Input) -> Int {
		let grid = input.grid

		guard let startPosition = grid.findFirst(tile: .start) else {
			preconditionFailure()
		}

		var cache: [Int: Int] = [:]

		return solveBeam(from: startPosition, grid: grid, memoization: &cache)
	}

	func parseInput(rawString: String) -> Input {
		.init(grid: rawString.parseGrid2D())
	}
}
