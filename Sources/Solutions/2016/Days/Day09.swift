import Foundation
import Tools

final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	private var input: Input!

	private struct Input {
		let string: String
	}

	private func decompressedLength(for string: AsciiString, recursive: Bool = false) -> Int {
		var result = 0

		var remainingString = string

		while remainingString.isNotEmpty {
			if let openIndex = remainingString.firstIndex(of: .openParenthesis), let closeIndex = remainingString.firstIndex(of: .closeParenthesis) {
				guard openIndex < closeIndex else {
					fatalError()
				}

				result += openIndex - 0

				guard let values = AsciiString(remainingString[openIndex ... closeIndex]).string.getCapturedValues(pattern: #"([0-9]*)x([0-9]*)"#) else {
					fatalError()
				}

				let count = Int(values[0])!
				let repetition = Int(values[1])!

				if recursive {
					let subString = remainingString[closeIndex + 1 ..< closeIndex + 1 + count]

					let repeatingSectionLength = decompressedLength(for: AsciiString(subString), recursive: true)

					result += repetition * repeatingSectionLength
				} else {
					result += count * repetition
				}

				remainingString = AsciiString(remainingString[closeIndex + 1 + count ..< remainingString.endIndex])
			} else {
				result += remainingString.count

				return result
			}
		}

		return result
	}

	func solvePart1() -> Int {
		let asciiString = AsciiString(string: input.string)

		return decompressedLength(for: asciiString)
	}

	func solvePart2() -> Int {
		let asciiString = AsciiString(string: input.string)

		return decompressedLength(for: asciiString, recursive: true)
	}

	func parseInput(rawString: String) {
		input = .init(string: rawString.trimmingCharacters(in: .whitespacesAndNewlines))
	}
}
