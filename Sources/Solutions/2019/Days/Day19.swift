import Collections
import Foundation
import Tools

final class Day19Solver: DaySolver {
	let dayNumber: Int = 19

	let expectedPart1Result = 158
	let expectedPart2Result = 6191165

	private var input: Input!

	private struct Input {
		let program: [Int]
	}

	func solvePart1() -> Int {
		var counter = 0
		for y in 0 ..< 50 {
			for x in 0 ..< 50 {
				let intcode = IntcodeProcessor(program: input.program)

				guard let output = intcode.continueProgramTillOutput(input: [x, y]) else {
					break
				}

				counter += output
			}
		}

		return counter
	}

	func solvePart2() -> Int {
		var slidingWindow: Deque<(y: Int, startX: Int, endX: Int)> = []

		for y in 1100 ..< 10_000 {
			var startX: Int = -1
			var endX: Int = -1

			var x = 350
			while x < 1_000 {
				let intcode = IntcodeProcessor(program: input.program)

				let output = intcode.continueProgramTillOutput(input: [x, y])!

				if output == 1, startX == -1 {
					startX = x

					x += 100
				} else if output == 0, startX != -1 {
					endX = x - 1

					break
				}

				x += 1
			}

			if (endX - startX) + 1 >= 100 {
				slidingWindow.append((y: y, startX: startX, endX: endX))
			} else {
				slidingWindow.removeAll()
			}

			if slidingWindow.count == 100 {
				let bottomLeftStartX = slidingWindow.last!.startX
				let topRightEndX = slidingWindow.first!.endX

				if (topRightEndX - bottomLeftStartX + 1) >= 100 {
					return (bottomLeftStartX * 10_000) + slidingWindow.first!.y
				} else {
					slidingWindow.removeFirst()
				}
			}
		}

		fatalError()
	}

	func parseInput(rawString: String) {
		input = .init(program: rawString.parseCommaSeparatedInts())
	}
}
