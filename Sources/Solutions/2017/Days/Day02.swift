import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	struct Input {
		let rows: [[Int]]
	}

	func solvePart1(withInput input: Input) -> Int {
		var sum = 0

		for row in input.rows {
			sum += row.max()! - row.min()!
		}

		return sum
	}

	func solvePart2(withInput input: Input) -> Int {
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

	func parseInput(rawString: String) -> Input {
		let rows: [[Int]] = rawString.allLines().map {
			$0.components(separatedBy: "\t").map { Int($0)! }
		}

		return .init(rows: rows)
	}
}
