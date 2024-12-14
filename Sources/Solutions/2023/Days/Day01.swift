import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	struct Input {
		let lines: [String]
	}

	func solvePart1(withInput input: Input) -> Int {
		input.lines.reduce(0) { result, value in
			let digits = value.compactMap { Int(String($0)) }

			return result + (digits.first! * 10) + digits.last!
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		let mappings: [String: Int] = [
			"one": 1,
			"two": 2,
			"three": 3,
			"four": 4,
			"five": 5,
			"six": 6,
			"seven": 7,
			"eight": 8,
			"nine": 9,
		]

		var sum = 0
		for line in input.lines {
			var digits: [Int] = []

			lineLoop: for position in 0 ..< line.count {
				if let digit = Int(String(line[position])) {
					digits.append(digit)
				} else {
					for mapping in mappings {
						if line[position ..< line.count].hasPrefix(mapping.key) {
							digits.append(mapping.value)

							break
						}
					}
				}
			}

			sum += (digits.first! * 10) + digits.last!
		}

		return sum
	}

	func parseInput(rawString: String) -> Input {
		return .init(lines: rawString.allLines())
	}
}
