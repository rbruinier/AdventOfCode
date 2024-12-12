import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	private var input: Input!

	private struct Input {
		let rows: [[Int]]
	}

	func solvePart1() -> Int {
		var sum = 0

		for row in input.rows {
			sum += row.max()! - row.min()!
		}

		return sum
	}

	func solvePart2() -> Int {
		var sum = 0

		for row in input.rows {
			loop: for i in 0 ..< row.count {
				for j in 0 ..< row.count where i != j && row[i] >= (row[j] * 2) {
					if row[i] % row[j] == 0 {
						sum += row[i] / row[j]

						break loop
					}
				}
			}
		}

		return sum
	}

	func parseInput(rawString: String) {
		let rows: [[Int]] = rawString.allLines().map {
			$0.components(separatedBy: "\t").map { Int($0)! }
		}

		input = .init(rows: rows)
	}
}
