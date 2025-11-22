import Foundation
import Tools

final class Day21Solver: DaySolver {
	let dayNumber: Int = 21

	private var cachedResult: Result!

	struct Input {}

	private struct Result {
		let lowestNumberOfInstructions: Int
		let highestNumberOfInstructions: Int
	}

	// Manually reverse engineered the program. R0 is the input of the test and the only place it is used is in a check
	// on line 28. If R3 is equal to input the program will halt. So we need to run the code till we get to line 28 because
	// whatever value R3 is at that moment would cause the code to finish if it was the input in R0. This is the answer for
	// part 1. To find part 2 we keep on going till R3 numbers start to repeat. The last unique value is the input number
	// with the most instructions needed.
	private func reverseEngineeredImplementation() -> Result {
		var uniqueR3s: Set<Int> = []

		var firstFoundR3Value = 0
		var lastUniqueR3Value = 0

		// r5 is IP but has no purpose in our implementation

		var r0 = 0, r1 = 0, r2 = 0, r3 = 0, r4 = 0

		// This part is useless:

		// 00 seti 123 0 3
		// 01 bani 3 456 3
		// 02 eqri 3 72 3
		// 03 addr 3 5 5
		// 04 seti 0 0 5
		// 05 seti 0 0 3

		while true {
			// 06 bori 3 65536 2
			r2 = r3 | 65536

			// 07 seti 14070682 0 3
			r3 = 14070682

			// 08 bani 2 255 1
			while true {
				r1 = r2 & 255

				// 09 addr 3 1 3
				r3 = r3 + r1

				// 10 bani 3 16777215 3
				r3 = r3 & 16777215

				// 11 muli 3 65899 3
				r3 = r3 * 65899

				// 12 bani 3 16777215 3
				r3 = r3 & 16777215

				// 13 gtir 256 2 1
				r1 = r2 < 256 ? 1 : 0

				if r1 == 1 {
					break
				}

				// 14 addr 1 5 5

				// 15 addi 5 1 5 // we skip 16 as we add extra 1 to IP

				// 16 seti 27 8 5

				// 17 seti 0 3 1
				r1 = 0

				// 18 addi 1 1 4
				while true {
					r4 = r1 + 1

					// 19 muli 4 256 4
					r4 = r4 * 256

					// 20 gtrr 4 2 4
					r4 = r4 > r2 ? 1 : 0

					if r4 == 1 {
						break
					}

					// 21 addr 4 5 5

					// 22 addi 5 1 5 // we jump to 24

					// 23 seti 25 8 5

					// 24 addi 1 1 1
					r1 += 1

					// 25 seti 17 9 5
				}

				// 26 setr 1 4 2
				r2 = r1

				// 27 seti 7 5 5 -> go to 8
			}

			// 28 eqrr 3 0 1
			r1 = r3 == r0 ? 1 : 0

			if uniqueR3s.isEmpty {
				firstFoundR3Value = r3
			}

			if !uniqueR3s.contains(r3) {
				uniqueR3s.insert(r3)

				lastUniqueR3Value = r3
			} else {
				break
			}

			// 29 addr 1 5 5
			// 30 seti 5 4 5
		}

		return .init(lowestNumberOfInstructions: firstFoundR3Value, highestNumberOfInstructions: lastUniqueR3Value)
	}

	func solvePart1(withInput input: Input) -> Int {
		cachedResult = reverseEngineeredImplementation()

		return cachedResult.lowestNumberOfInstructions
	}

	func solvePart2(withInput input: Input) -> Int {
		cachedResult.highestNumberOfInstructions
	}

	func parseInput(rawString: String) -> Input {
		.init()
	}
}
