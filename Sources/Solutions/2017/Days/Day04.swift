import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	struct Input {
		let passphrases: [String]
	}

	func solvePart1(withInput input: Input) -> Int {
		var validPhrases = 0

		mainLoop: for passphrase in input.passphrases {
			let words = passphrase.components(separatedBy: " ").sorted()

			for i in 0 ..< words.count - 1 {
				if words[i] == words[i + 1] {
					continue mainLoop
				}
			}

			validPhrases += 1
		}

		return validPhrases
	}

	func solvePart2(withInput input: Input) -> Int {
		var validPhrases = 0

		mainLoop: for passphrase in input.passphrases {
			let words = passphrase.components(separatedBy: " ").map { String($0.sorted()) }.sorted()

			for i in 0 ..< words.count - 1 {
				if words[i] == words[i + 1] {
					continue mainLoop
				}
			}

			validPhrases += 1
		}

		return validPhrases
	}

	func parseInput(rawString: String) -> Input {
		.init(passphrases: rawString.allLines())
	}
}
