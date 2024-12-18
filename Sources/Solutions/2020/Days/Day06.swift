import Foundation
import Tools

final class Day06Solver: DaySolver {
	let dayNumber: Int = 6

	struct Input {
		let groups: [Group]
	}

	struct Group {
		let answers: [[String]]

		var uniqueAnswers: [String] {
			Array(Set(answers.flatMap { $0 }))
		}

		var sharedAnswers: [String] {
			let uniqueAnswers = uniqueAnswers

			return uniqueAnswers.filter { uniqueAnswer in
				answers.filter { $0.contains(uniqueAnswer) }.count == answers.count
			}
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		input.groups.reduce(0) { result, group in
			result + group.uniqueAnswers.count
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		input.groups.reduce(0) { result, group in
			result + group.sharedAnswers.count
		}
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines(includeEmpty: true)

		var groups: [Group] = []
		var groupAnswers: [[String]] = []

		for line in lines {
			if line.isEmpty {
				groups.append(.init(answers: groupAnswers))

				groupAnswers.removeAll()

				continue
			}

			groupAnswers.append(line.map { String($0) })
		}

		return .init(groups: groups)
	}
}
