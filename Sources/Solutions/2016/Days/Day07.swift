import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	struct Input {
		let strings: [String]
	}

	private func supportsTLS(ip: String) -> Bool {
		let ipAsAscii = ip.asAsciiArray

		var inBracket = false
		var startIndex = 0

		var hasMatch = false

		for (index, character) in ipAsAscii.enumerated() {
			if character == .openBracket {
				inBracket = true

				startIndex = index + 1

				continue
			} else if character == .closeBracket {
				inBracket = false

				startIndex = index + 1

				continue
			} else if index - startIndex < 3 {
				continue
			}

			if ipAsAscii[index - 3] == character, ipAsAscii[index - 2] == ipAsAscii[index - 1], ipAsAscii[index - 1] != character {
				if inBracket {
					return false
				}

				hasMatch = true
			}
		}

		return hasMatch
	}

	private func supportsSSL(ip: String) -> Bool {
		let ipAsAscii = ip.asAsciiArray

		var inBracket = false
		var startIndex = 0

		var foundBABs: Set<[UInt8]> = []
		var foundABAs: Set<[UInt8]> = []

		for (index, character) in ipAsAscii.enumerated() {
			if character == .openBracket {
				inBracket = true

				startIndex = index + 1

				continue
			} else if character == .closeBracket {
				inBracket = false

				startIndex = index + 1

				continue
			} else if index - startIndex < 2 {
				continue
			}

			if ipAsAscii[index - 2] == ipAsAscii[index], ipAsAscii[index - 2] != ipAsAscii[index - 1] {
				if inBracket {
					foundBABs.insert(Array(ipAsAscii[index - 2 ... index]))
				} else {
					foundABAs.insert(Array(ipAsAscii[index - 2 ... index]))
				}
			}
		}

		for foundBAB in foundBABs {
			let aba: [UInt8] = [foundBAB[1], foundBAB[0], foundBAB[1]]

			if foundABAs.contains(aba) {
				return true
			}
		}

		return false
	}

	func solvePart1(withInput input: Input) -> Int {
		input.strings.filter { supportsTLS(ip: $0) }.count
	}

	func solvePart2(withInput input: Input) -> Int {
		input.strings.filter { supportsSSL(ip: $0) }.count
	}

	func parseInput(rawString: String) -> Input {
		.init(strings: rawString.allLines())
	}
}
