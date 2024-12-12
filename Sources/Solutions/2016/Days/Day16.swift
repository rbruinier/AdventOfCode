import Foundation
import Tools

final class Day16Solver: DaySolver {
	let dayNumber: Int = 16

	private var input: Input!

	private struct Input {
		let values: [Bool]
		let desiredLengthPart1: Int
		let desiredLengthPart2: Int
	}

	private func checksum(for values: [Bool]) -> [Bool] {
		var checksum = values
		while (checksum.count % 2) == 0 {
			var newChecksum: [Bool] = []

			newChecksum.reserveCapacity(checksum.count >> 1)

			var index = 0
			while index < checksum.count {
				newChecksum.append(checksum[index] == checksum[index + 1])

				index += 2
			}

			checksum = newChecksum
		}

		return checksum
	}

	private func fillDisc(startingWith firstValues: [Bool], length: Int) -> [Bool] {
		var values = firstValues

		while values.count < length {
			let newValues = values.reversed().negated()

			values = values + [false] + newValues
		}

		return Array(values[0 ..< length])
	}

	func solvePart1() -> String {
		let values = fillDisc(startingWith: input.values, length: input.desiredLengthPart1)
		let checksum = checksum(for: values)

		return checksum.map { $0 ? "1" : "0" }.joined()
	}

	func solvePart2() -> String {
		let values = fillDisc(startingWith: input.values, length: input.desiredLengthPart2)
		let checksum = checksum(for: values)

		return checksum.map { $0 ? "1" : "0" }.joined()
	}

	func parseInput(rawString: String) {
		input = .init(
			values: "11100010111110100".map { $0 == "1" ? true : false },
			desiredLengthPart1: 272,
			desiredLengthPart2: 35651584
		)
	}
}
