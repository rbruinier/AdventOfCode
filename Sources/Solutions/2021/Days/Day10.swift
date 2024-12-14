import Foundation
import Tools

final class Day10Solver: DaySolver {
	let dayNumber: Int = 10

	struct Input {
		let lines: [[Character]]
	}

	private enum Validation: Equatable {
		case valid
		case incomplete(remainingStack: [Character])
		case corrupted(wrongCharacter: Character)
	}

	private func validateLine(_ line: [Character]) -> Validation {
		var stack: [Character] = []

		for character in line {
			switch character {
			case "(",
			     "[",
			     "{",
			     "<":
				stack.append(character)
			case ")",
			     "]",
			     "}",
			     ">":
				let matching: Bool

				switch character {
				case ")": matching = stack.last == "("
				case "]": matching = stack.last == "["
				case "}": matching = stack.last == "{"
				case ">": matching = stack.last == "<"
				default: fatalError("Invalid charachter")
				}

				if matching == false {
					return .corrupted(wrongCharacter: character)
				}

				stack.removeLast()
			default:
				fatalError("Unknown character: \(character)")
			}
		}

		return stack.isEmpty ? .valid : .incomplete(remainingStack: stack)
	}

	func solvePart1(withInput input: Input) -> Int {
		let validations: [Validation] = input.lines.map(validateLine)

		let score = validations.reduce(0) { result, validation in
			switch validation {
			case .corrupted(let wrongCharacter):
				switch wrongCharacter {
				case ")": result + 3
				case "]": result + 57
				case "}": result + 1197
				case ">": result + 25137
				default: fatalError("Unexpected character")
				}
			default:
				result
			}
		}

		return score
	}

	func solvePart2(withInput input: Input) -> Int {
		let validations: [Validation] = input.lines.map(validateLine)

		let scores: [Int] = validations.compactMap { validation in
			switch validation {
			case .incomplete(let remainingStack):
				remainingStack.reversed().reduce(0) { result, character in
					let score: Int

					switch character {
					case "(": score = 1
					case "[": score = 2
					case "{": score = 3
					case "<": score = 4
					default: fatalError("Unexpected character")
					}

					return (result! * 5) + score
				}
			default:
				nil
			}
		}

		return scores.sorted()[scores.count >> 1]
	}

	func parseInput(rawString: String) -> Input {
		let rawLines = rawString
			.components(separatedBy: CharacterSet.newlines)
			.filter { $0.isEmpty == false }

		let lines = rawLines.map { [Character]($0) }

		return .init(lines: lines)
	}
}
