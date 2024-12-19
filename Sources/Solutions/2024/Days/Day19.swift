import Foundation
import Tools

final class Day19Solver: DaySolver {
	let dayNumber: Int = 19

	enum Color: String, Equatable, Hashable, CustomStringConvertible {
		case white = "w"
		case blue = "u"
		case black = "b"
		case red = "r"
		case green = "g"

		var description: String {
			rawValue
		}
	}

	struct Input {
		let patterns: [[Color]]
		let designs: [[Color]]
	}

	/// Use hash value of (remaining) design as key and value is the number of valid (sub) combinations of patterns
	private var memoization: [Int: Int] = [:]

	private func numberOfPossibleCombinations(design: [Color], patterns: [[Color]]) -> Int {
		let designHashValue = design.hashValue

		if let memoizedValue = memoization[designHashValue] {
			return memoizedValue
		}

		var valid = 0

		for pattern in patterns where pattern.count <= design.count {
			// if we match we continue with remaining design
			if pattern == Array(design[0 ..< pattern.count]) {
				let remainingDesign = Array(design[pattern.count...])

				if remainingDesign.isNotEmpty {
					valid += numberOfPossibleCombinations(design: remainingDesign, patterns: patterns)
				} else {
					valid += 1
				}
			}
		}

		memoization[designHashValue] = valid

		return valid
	}

	func solvePart1(withInput input: Input) -> Int {
		var result = 0

		for design in input.designs {
			result += numberOfPossibleCombinations(design: design, patterns: input.patterns) > 0 ? 1 : 0
		}

		return result
	}

	func solvePart2(withInput input: Input) -> Int {
		var result = 0

		for design in input.designs {
			result += numberOfPossibleCombinations(design: design, patterns: input.patterns)
		}

		return result
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines()

		let patterns: [[Color]] = lines[0].components(separatedBy: ", ").map { $0.map { Color(rawValue: String($0))! } }
		let designs: [[Color]] = lines[1...].map { $0.map { Color(rawValue: String($0))! }}

		return .init(patterns: patterns, designs: designs)
	}
}
