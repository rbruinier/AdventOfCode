import Foundation
import Tools

final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	private var input: Input!

	private struct Input {
		let numberOfPlayers: Int
		let lastMarbleWorth: Int
	}

	private func solve(forNumberOfPlayers numberOfPlayers: Int, numberOfMarbles: Int) -> Int {
		var playerScores: [Int: Int] = [:]

		let marbles = DoublyLinkedIntList([0])

		for marble in 1 ... numberOfMarbles {
			let playerIndex = ((marble - 1) % numberOfPlayers) + 1

			if marble % 23 == 0 {
				marbles.rotate(steps: 7)

				playerScores[playerIndex, default: 0] += marble + marbles.popLast()!

				marbles.rotate(steps: -1)
			} else {
				marbles.rotate(steps: -1)

				marbles.append(marble)
			}
		}

		return playerScores.values.max()!
	}

	func solvePart1() -> Int {
		solve(forNumberOfPlayers: input.numberOfPlayers, numberOfMarbles: input.lastMarbleWorth)
	}

	func solvePart2() -> Int {
		solve(forNumberOfPlayers: input.numberOfPlayers, numberOfMarbles: input.lastMarbleWorth * 100)
	}

	func parseInput(rawString: String) {
		input = .init(Input(numberOfPlayers: 411, lastMarbleWorth: 71170))
	}
}
