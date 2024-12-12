import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	private var input: Input!

	struct Report {
		let levels: [Int]
	}

	private struct Input {
		let reports: [Report]
	}

	private func isSafe(levels: [Int]) -> Bool {
		let isIncreasing = levels.last! > levels.first!

		for index in 1 ..< levels.count {
			let delta = levels[index] - levels[index - 1]

			guard (1 ... 3).contains(abs(delta)), (isIncreasing && delta > 0) || (!isIncreasing && delta < 0) else {
				return false
			}
		}

		return true
	}

	private func isSafeWithErrorMargin(levels: [Int]) -> Bool {
		if isSafe(levels: levels) {
			return true
		}

		for index in 0 ..< levels.count {
			var newLevels = levels

			newLevels.remove(at: index)

			if isSafe(levels: newLevels) {
				return true
			}
		}

		return false
	}

	func solvePart1() -> Int {
		input.reports.count { isSafe(levels: $0.levels) }
	}

	func solvePart2() -> Int {
		input.reports.count { isSafeWithErrorMargin(levels: $0.levels) }
	}

	func parseInput(rawString: String) {
		let reports: [Report] = rawString.allLines().map { line in
			Report(levels: line.components(separatedBy: .whitespaces).map { Int($0)! })
		}

		input = .init(reports: reports)
	}
}
