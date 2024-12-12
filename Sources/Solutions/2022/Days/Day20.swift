import Foundation
import Tools

/// This was more painful than it should have been. Luckily part 2 was easy.
///
/// My assumption was that the input digits where unique and this really messed up everything. Because they are not unique and you need to move the correct entry the digits are now
/// stored as pairs combined with the index.
final class Day20Solver: DaySolver {
	let dayNumber: Int = 20

	private var input: Input!

	private struct Pair: Hashable {
		let index: Int
		let digit: Int
	}

	private struct Input {
		let digits: [Pair]
	}

	init() {}

	private func runDecryption(on digits: [Pair], rounds: Int, multiplier: Int) -> Int {
		let multipliedDigits: [Pair] = digits.map { .init(index: $0.index, digit: $0.digit * multiplier) }

		var digits = multipliedDigits

		for _ in 0 ..< rounds {
			for pair in multipliedDigits {
				let originalIndex = digits.firstIndex(of: pair)!

				digits.remove(at: originalIndex)

				let insertIndex = mod(originalIndex + pair.digit, digits.count)

				if insertIndex == 0 {
					digits.append(pair)
				} else {
					digits.insert(pair, at: insertIndex)
				}
			}
		}

		let zeroPosition = digits.firstIndex { $0.digit == 0 }!

		let finalDigits = digits.map(\.digit)

		var sum = 0
		for position in [1000, 2000, 3000] {
			sum += finalDigits[(zeroPosition + position) % finalDigits.count]
		}

		return sum
	}

	func solvePart1() -> Int {
		runDecryption(on: input.digits, rounds: 1, multiplier: 1)
	}

	func solvePart2() -> Int {
		runDecryption(on: input.digits, rounds: 10, multiplier: 811589153)
	}

	func parseInput(rawString: String) {
		input = .init(digits: rawString.allLines().enumerated().map { .init(index: $0, digit: Int($1)!) })
	}
}
