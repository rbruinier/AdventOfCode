import Foundation
import Tools

final class Day05Solver: DaySolver {
	let dayNumber: Int = 5

	private var input: Input!

	private struct Input {
		let strings: [String]
	}

	private func isNicePart1(string: String) -> Bool {
		var foundVowels = 0

		let badSubstrings: [String] = ["ab", "cd", "pq", "xy"]
		var previousCharacter: Character = " "
		var foundTwiceInRow = false

		for badSubstring in badSubstrings {
			if string.contains(badSubstring) {
				return false
			}
		}

		for character in string {
			if "eaiou".contains(character) {
				foundVowels += 1
			}

			if character == previousCharacter {
				foundTwiceInRow = true
			}

			previousCharacter = character
		}

		guard foundVowels >= 3 else {
			return false
		}

		return foundTwiceInRow
	}

	private func isNicePart2(string: String) -> Bool {
		var foundPairs: [String] = []

		var foundMatchingPair = false
		var foundRepeatingLetter = false

		for (index, character) in string.enumerated() {
			if index >= 1, foundMatchingPair == false {
				let pair = String(string[index - 1 ... index])

				if index >= 2, foundPairs[0 ..< index - 2].contains(pair) {
					foundMatchingPair = true
				} else {
					foundPairs.append(pair)
				}
			}

			if index >= 2, foundRepeatingLetter == false {
				if String(character) == String(string[index - 2 ... index - 2]) {
					foundRepeatingLetter = true
				}
			}
		}

		return foundMatchingPair && foundRepeatingLetter
	}

	func solvePart1() -> Int {
		input.strings.filter(isNicePart1(string:)).count
	}

	func solvePart2() -> Int {
		input.strings.filter(isNicePart2(string:)).count
	}

	func parseInput(rawString: String) {
		input = .init(strings: rawString.allLines())
	}
}
