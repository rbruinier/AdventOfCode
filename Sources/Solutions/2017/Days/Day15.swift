import Foundation
import Tools

final class Day15Solver: DaySolver {
	let dayNumber: Int = 15

	struct Input {
		let a: Int
		let b: Int
	}

	func solvePart1(withInput input: Input) -> Int {
		var a = input.a
		var b = input.b

		var counter = 0
		for _ in 0 ..< 40_000_000 {
			a = (a * 16807) % 2147483647
			b = (b * 48271) % 2147483647

			if (a & 0xFFFF) == (b & 0xFFFF) {
				counter += 1
			}
		}

		return counter
	}

	func solvePart2(withInput input: Input) -> Int {
		var a = input.a
		var b = input.b

		var counter = 0

		var aStack: [UInt16] = []
		var bStack: [UInt16] = []

		aStack.reserveCapacity(10_000_000)
		bStack.reserveCapacity(5_000_000)

		var comparePointer = 0

		while comparePointer < 5_000_000 {
			a = (a * 16807) % 2147483647
			b = (b * 48271) % 2147483647

			if a % 4 == 0 {
				aStack.append(UInt16(a & 0xFFFF))
			}

			if b % 8 == 0 {
				bStack.append(UInt16(b & 0xFFFF))
			}

			if comparePointer < aStack.count, comparePointer < bStack.count {
				if aStack[comparePointer] == bStack[comparePointer] {
					counter += 1
				}

				comparePointer += 1
			}
		}

		return counter
	}

	func parseInput(rawString: String) -> Input {
		return .init(a: 512, b: 191)
	}
}
