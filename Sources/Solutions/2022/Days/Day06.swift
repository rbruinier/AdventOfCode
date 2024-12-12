import Foundation
import Tools

final class Day06Solver: DaySolver {
	let dayNumber: Int = 6

	private var input: Input!

	private struct Input {
		let buffer: String
	}

	init() {}

	private func scan(buffer: String, count: Int) -> Int {
		for i in 0 ..< buffer.count {
			if Set(buffer[i ..< i + count]).count == count {
				return i + count
			}
		}

		fatalError()
	}

	func solvePart1() -> Int {
		scan(buffer: input.buffer, count: 4)
	}

	func solvePart2() -> Int {
		scan(buffer: input.buffer, count: 14)
	}

	func parseInput(rawString: String) {
		input = .init(buffer: rawString.allLines().first!)
	}
}
