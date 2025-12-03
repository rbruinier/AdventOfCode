import Foundation
import Tools

final class Day03Solver: DaySolver {
	let dayNumber: Int = 3

	private var input: Input!

	struct Input {
		let banks: [[Int]]
	}

	private func solveBank(_ bank: [Int], numberOfBatteries: Int) -> Int {
		var joltage = 0
		var currentStartIndex = 0

		for batteryIndex in 0 ..< numberOfBatteries {
			var bestIndex = 0
			var highestValue = 0

			for index in currentStartIndex ..< bank.count - (numberOfBatteries - 1 - batteryIndex) {
				if bank[index] > highestValue {
					highestValue = bank[index]
					bestIndex = index
				}
			}

			currentStartIndex = bestIndex + 1

			joltage = (joltage * 10) + highestValue
		}

		return joltage
	}

	func solvePart1(withInput input: Input) -> Int {
		var sum = 0

		for bank in input.banks {
			sum += solveBank(bank, numberOfBatteries: 2)
		}

		return sum
	}

	func solvePart2(withInput input: Input) -> Int {
		var sum = 0

		for bank in input.banks {
			sum += solveBank(bank, numberOfBatteries: 12)
		}

		return sum
	}

	func parseInput(rawString: String) -> Input {
		let banks: [[Int]] = rawString.allLines().map { line in
			line.map { Int(String($0))! }
		}

		return .init(banks: banks)
	}
}
