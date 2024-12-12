import Foundation
import Tools

final class Day18Solver: DaySolver {
	let dayNumber: Int = 18

	private var input: Input!

	private struct Input {
		let firstRow: [Cell]
	}

	private enum Cell: CustomStringConvertible {
		case safe
		case trap

		var description: String {
			switch self {
			case .safe: "."
			case .trap: "^"
			}
		}
	}

	private func nextRow(of row: [Cell]) -> [Cell] {
		let cellCount = row.count
		let cellRange = 0 ..< cellCount

		var result: [Cell] = Array(reservedCapacity: cellCount)

		for (index, center) in row.enumerated() {
			let left = cellRange.contains(index - 1) ? row[index - 1] : .safe
			let right = cellRange.contains(index + 1) ? row[index + 1] : .safe

			result.append(((left == .trap && center == .trap && right == .safe) ||
					(right == .trap && center == .trap && left == .safe) ||
					(left == .trap && center == .safe && right == .safe) ||
					(right == .trap && center == .safe && left == .safe)) ? .trap : .safe
			)
		}

		return result
	}

	private func solve(with initialRow: [Cell], count: Int) -> Int {
		var currentRow = initialRow

		var safeSum = initialRow.filter { $0 == .safe }.count

		// first row is already included
		for _ in 1 ..< count {
			currentRow = nextRow(of: currentRow)

			safeSum += currentRow.filter { $0 == .safe }.count
		}

		return safeSum
	}

	func solvePart1() -> Int {
		solve(with: input.firstRow, count: 40)
	}

	func solvePart2() -> Int {
		solve(with: input.firstRow, count: 400_000)
	}

	func parseInput(rawString: String) {
		input = .init(Input(firstRow: rawString.allLines().first!.map {
			$0 == "." ? .safe : .trap
		}))
	}
}
