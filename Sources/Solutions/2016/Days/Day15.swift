import Foundation
import Tools

/// Brute force works well enough
final class Day15Solver: DaySolver {
	let dayNumber: Int = 15

	struct Input {
		let discs: [Disc]
	}

	private struct Disc {
		let nrOfPositions: Int
		var position: Int
	}

	func solvePart1(withInput input: Input) -> Int {
		let discs = input.discs

		for loop in 0 ..< 1_000_000 {
			var notZero = false

			for index in 0 ..< discs.count {
				let position = (discs[index].position + loop + (index + 1)) % discs[index].nrOfPositions

				if position != 0 {
					notZero = true

					break
				}
			}

			if notZero == false {
				return loop
			}
		}

		fatalError()
	}

	func solvePart2(withInput input: Input) -> Int {
		var discs = input.discs

		discs.append(.init(nrOfPositions: 11, position: 0))

		for loop in 0 ..< 10_000_000 {
			var notZero = false

			for (index, disc) in discs.enumerated() {
				let position = (disc.position + loop + (index + 1)) % disc.nrOfPositions

				if position != 0 {
					notZero = true

					break
				}
			}

			if notZero == false {
				return loop
			}
		}

		fatalError()
	}

	func parseInput(rawString: String) -> Input {
		return .init(discs: [
			.init(nrOfPositions: 13, position: 1),
			.init(nrOfPositions: 19, position: 10),
			.init(nrOfPositions: 3, position: 2),
			.init(nrOfPositions: 7, position: 1),
			.init(nrOfPositions: 5, position: 3),
			.init(nrOfPositions: 17, position: 5),
		])
	}
}
