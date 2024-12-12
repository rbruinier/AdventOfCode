import Collections
import Foundation
import Tools

final class Day19Solver: DaySolver {
	let dayNumber: Int = 19

	private var input: Input!

	private struct Input {
		let numberOfElves: Int
	}

	func solvePart1() -> Int {
		// first elf is always taking next elf items, so next elf always is removed
		// use a deque for quickly removing first and appending last items

		var currentElvesWithPresent: Deque<Int> = Deque((1 ... input.numberOfElves).map { $0 })

		while currentElvesWithPresent.count >= 2 {
			let first = currentElvesWithPresent.removeFirst()

			currentElvesWithPresent.removeFirst()

			currentElvesWithPresent.append(first)
		}

		return currentElvesWithPresent.first!
	}

	func solvePart2() -> Int {
		// removing items in the center of a deque is slow, we split it in two instead

		let halfCount = (input.numberOfElves / 2)

		var half1: Deque<Int> = Deque((1 ... halfCount).map { $0 })
		var half2: Deque<Int> = Deque((halfCount + 1 ... input.numberOfElves).map { $0 })

		while half1.count > 1 {
			if half1.count > half2.count {
				half1.removeLast()
			} else {
				half2.removeFirst()
			}

			half1.append(half2.removeFirst())
			half2.append(half1.removeFirst())
		}

		return half1.first!
	}

	func parseInput(rawString: String) {
		input = .init(numberOfElves: 3012210)
	}
}
