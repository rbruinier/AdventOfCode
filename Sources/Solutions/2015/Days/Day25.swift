import Foundation
import Tools

final class Day25Solver: DaySolver {
	let dayNumber: Int = 25

	struct Input {}

	func solvePart1(withInput input: Input) -> Int {
		func startNumberForColumn(_ column: Int) -> Int { // triangular number sequence
			(column * (column + 1)) / 2
		}

		func numberForColumn(_ column: Int, row: Int) -> Int {
			var current = startNumberForColumn(column)

			var increment = column

			for _ in 1 ..< row {
				current += increment
				increment += 1
			}

			return current
		}

		func valueForColumn(_ column: Int, row: Int) -> Int { // brute force actual result
			let count = numberForColumn(column, row: row)

			var currentValue = 20151125

			for _ in 1 ..< count {
				currentValue = (currentValue * 252533) % 33554393
			}

			return currentValue
		}

		return valueForColumn(3029, row: 2947)
	}

	func solvePart2(withInput input: Input) -> String {
		"Merry Christmas 🎄"
	}

	func parseInput(rawString: String) -> Input {
		return .init()
	}
}
