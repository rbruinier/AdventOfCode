import Foundation
import Tools

final class Day19Solver: DaySolver {
	let dayNumber: Int = 19

	struct Input {
		let rules: [Int: Rule]

		let strings: [String]
	}

	enum Rule {
		case literal(character: String)
		case rule(groups: [[Int]])
	}

	private func matchRule(_ rule: Rule, strings: [String], rules: [Int: Rule]) -> [String] {
		var remainingStrings: [String] = []

		for string in strings {
			guard string.isNotEmpty else {
				return []
			}

			switch rule {
			case .literal(let character):
				if String(string.first!) == character {
					remainingStrings.append(String(string[string.index(string.startIndex, offsetBy: 1) ..< string.endIndex]))
				}
			case .rule(let groups):
				var count = 0

				for group in groups {
					var subRemainingStrings: [String] = [string]

					for subRuleIndex in group {
						let subRule = rules[subRuleIndex]!

						subRemainingStrings = matchRule(subRule, strings: subRemainingStrings, rules: rules)

						if subRemainingStrings.isEmpty {
							break
						}
					}

					if subRemainingStrings.isNotEmpty {
						remainingStrings.append(contentsOf: subRemainingStrings)

						count += 1
					}
				}
			}
		}

		return remainingStrings
	}

	func solvePart1(withInput input: Input) -> Int {
		var validCount = 0
		for stringIndex in 0 ..< input.strings.count {
			let string = input.strings[stringIndex]

			let remainingStrings = matchRule(input.rules[0]!, strings: [string], rules: input.rules)

			validCount += remainingStrings.contains { $0 == "" } ? 1 : 0
		}

		return validCount
	}

	func solvePart2(withInput input: Input) -> Int {
		var rules = input.rules

		rules[8] = .rule(groups: [[42], [42, 8]])
		rules[11] = .rule(groups: [[42, 31], [42, 11, 31]])

		var validCount = 0
		for stringIndex in 0 ..< input.strings.count {
			let string = input.strings[stringIndex]

			let remainingStrings = matchRule(input.rules[0]!, strings: [string], rules: rules)

			validCount += remainingStrings.contains { $0 == "" } ? 1 : 0
		}

		return validCount
	}

	func parseInput(rawString: String) -> Input {
		var lines = rawString.allLines(includeEmpty: true)

		var rules: [Int: Rule] = [:]
		while true {
			let line = lines.removeFirst()

			if line.isEmpty {
				break
			}

			let components = line.components(separatedBy: ": ")

			let ruleID = Int(components[0])!

			if components[1].starts(with: "\"") {
				rules[ruleID] = .literal(character: String(components[1].replacingOccurrences(of: "\"", with: "")))
			} else {
				let ruleGroups: [[Int]] = components[1].components(separatedBy: " | ").map {
					let groupItems: [Int] = $0.components(separatedBy: .whitespaces).map {
						Int($0)!
					}

					return groupItems
				}

				rules[ruleID] = .rule(groups: ruleGroups)
			}
		}

		return .init(rules: rules, strings: lines.filter(\.isNotEmpty))
	}
}
