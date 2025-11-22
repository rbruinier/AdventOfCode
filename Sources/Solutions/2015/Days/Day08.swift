import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	struct Input {
		let strings: [String]
	}

	private func numberOfSuperfluousCharacters(in originalString: String) -> Int {
		var index = 1

		var count = 2
		while index < originalString.count - 1 {
			let character = originalString[index ... index]

			if character == "\\" {
				let nextCharacter = originalString[index + 1 ... index + 1]

				if nextCharacter == "\\" || nextCharacter == "\"" {
					count += 1
					index += 1
				} else if nextCharacter == "x" {
					count += 3
					index += 2
				}
			}

			index += 1
		}

		return count
	}

	private func numberOfExtraEncodedCharacters(in originalString: String) -> Int {
		var count = 2
		for character in originalString {
			let character = String(character)

			if character == "\\" || character == "\"" {
				count += 1
			}
		}

		return count
	}

	func solvePart1(withInput input: Input) -> Int {
		var sumOfDifference = 0
		for string in input.strings {
			sumOfDifference += numberOfSuperfluousCharacters(in: string)
		}

		return sumOfDifference
	}

	func solvePart2(withInput input: Input) -> Int {
		var sumOfDifference = 0
		for string in input.strings {
			sumOfDifference += numberOfExtraEncodedCharacters(in: string)
		}

		return sumOfDifference
	}

	func parseInput(rawString: String) -> Input {
		.init(strings: rawString.allLines())
	}
}
