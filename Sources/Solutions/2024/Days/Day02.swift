import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	struct Report {
		let levels: [Int]
	}

	struct Input {
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

	func solvePart1(withInput input: Input) -> Int {
		input.reports.count { isSafe(levels: $0.levels) }
	}

	func solvePart2(withInput input: Input) -> Int {
		input.reports.count { isSafeWithErrorMargin(levels: $0.levels) }
	}

	func parseInput(rawString: String) -> Input {
		let reports: [Report] = rawString.allLines().map { line in
			Report(levels: line.components(separatedBy: .whitespaces).map { Int($0)! })
		}

		return .init(reports: reports)
	}
}
