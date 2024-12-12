import Foundation
import Tools

final class Day10Solver: DaySolver {
	let dayNumber: Int = 10

	private var input: Input!

	private struct Input {
		let lengths: [Int]
	}

	func solvePart1() -> Int {
		var numbers: [Int] = (0 ... 255).map { $0 }

		var skipSize = 0
		var currentPosition = 0

		for length in input.lengths {
			var newNumbers = numbers

			for i in 0 ..< length {
				newNumbers[(currentPosition + length - i - 1) % numbers.count] = numbers[(currentPosition + i) % numbers.count]
			}

			numbers = newNumbers
			currentPosition += length + skipSize
			skipSize += 1
		}

		return numbers[0] * numbers[1]
	}

	func solvePart2() -> String {
		var lengths = input.lengths
			.map { String(describing: $0) }
			.joined(separator: ",")
			.map { Int($0.asciiValue!) }

		lengths += [17, 31, 73, 47, 23]

		var numbers: [Int] = (0 ... 255).map { $0 }

		var skipSize = 0
		var currentPosition = 0

		for _ in 0 ..< 64 {
			for length in lengths {
				var newNumbers = numbers

				for i in 0 ..< length {
					newNumbers[(currentPosition + length - i - 1) % numbers.count] = numbers[(currentPosition + i) % numbers.count]
				}

				numbers = newNumbers
				currentPosition += length + skipSize
				skipSize += 1
			}
		}

		var denseHash: [Int] = []

		for hashOffset in stride(from: 0, to: 255, by: 16) {
			var hash = 0

			for offset in hashOffset ..< hashOffset + 16 {
				hash ^= numbers[offset]
			}

			denseHash.append(hash)
		}

		return denseHash.map { String(format: "%02hhx", $0) }.joined()
	}

	func parseInput(rawString: String) {
		input = .init(lengths: rawString.parseCommaSeparatedInts())
	}
}
