import Foundation
import Tools

final class Day05Solver: DaySolver {
	let dayNumber: Int = 5

	private var input: Input!

	private struct Rule {
		let a: Int
		let b: Int
	}

	private struct Input {
		let rules: [Rule]
		let updates: [[Int]]
	}

	private func isValidUpdate(_ update: [Int], rules: [Rule]) -> Bool {
		for (index, value) in update.enumerated() {
			for rule in rules.filter({ $0.a == value }) {
				if let bIndex = update.firstIndex(of: rule.b), index > bIndex {
					return false
				}
			}

			for rule in rules.filter({ $0.b == value }) {
				if let aIndex = update.firstIndex(of: rule.a), index < aIndex {
					return false
				}
			}
		}

		return true
	}

	private func fixUpdate(_ update: [Int], rules: [Rule]) -> [Int] {
		var currentUpdate = update

		fixLoop: while true {
			var newUpdate: [Int] = currentUpdate

			for (index, value) in currentUpdate.enumerated() {
				for rule in rules.filter({ $0.a == value }) {
					if let bIndex = currentUpdate.firstIndex(of: rule.b), index > bIndex {
						newUpdate.remove(at: index)
						newUpdate.insert(value, at: bIndex)

						currentUpdate = newUpdate

						continue fixLoop
					}
				}

				for rule in rules.filter({ $0.b == value }) {
					if let aIndex = currentUpdate.firstIndex(of: rule.a), index < aIndex {
						newUpdate.insert(value, at: aIndex + 1)
						newUpdate.remove(at: index)

						currentUpdate = newUpdate

						continue fixLoop
					}
				}
			}

			break
		}

		return currentUpdate
	}

	func solvePart1() -> Int {
		input.updates.map {
			isValidUpdate($0, rules: input.rules) ? $0[$0.count >> 1] : 0
		}.reduce(0, +)
	}

	func solvePart2() -> Int {
		input.updates
			.filter { !isValidUpdate($0, rules: input.rules) }
			.map {
				fixUpdate($0, rules: input.rules)[$0.count >> 1]
			}
			.reduce(0, +)
	}

	func parseInput(rawString: String) {
		var rules: [Rule] = []
		var updates: [[Int]] = []

		var parsingRules = true
		for line in rawString.allLines(includeEmpty: true) {
			if line.isEmpty {
				parsingRules = false

				continue
			}

			if parsingRules {
				let parts = line.split(separator: "|")

				rules.append(.init(a: Int(parts[0])!, b: Int(parts[1])!))
			} else {
				updates.append(line.parseCommaSeparatedInts())
			}
		}

		input = .init(rules: rules, updates: updates)
	}
}
