import Foundation
import Tools

final class Day06Solver: DaySolver {
	let dayNumber: Int = 6

	struct Input {
		let banks: [Int]
	}

	func solvePart1(withInput input: Input) -> Int {
		var banks = input.banks

		var previousBanks: Set<[Int]> = [banks]

		while true {
			let maxIndex = banks.firstIndex(of: banks.max()!)!

			let blocks = banks[maxIndex]

			banks[maxIndex] = 0

			for bankIndex in maxIndex + 1 ... maxIndex + blocks {
				banks[bankIndex % banks.count] += 1
			}

			if previousBanks.contains(banks) {
				break
			}

			previousBanks.insert(banks)
		}

		return previousBanks.count
	}

	func solvePart2(withInput input: Input) -> Int {
		var banks = input.banks

		var previousBanks: [[Int]: Int] = [:]

		var stepCounter = 0
		while true {
			let maxIndex = banks.firstIndex(of: banks.max()!)!

			let blocks = banks[maxIndex]

			banks[maxIndex] = 0

			for bankIndex in maxIndex + 1 ... maxIndex + blocks {
				banks[bankIndex % banks.count] += 1
			}

			stepCounter += 1

			if previousBanks.keys.contains(banks) {
				return stepCounter - previousBanks[banks]!
			}

			previousBanks[banks] = stepCounter
		}

		return previousBanks.count
	}

	func parseInput(rawString: String) -> Input {
		.init(banks: rawString.allLines().first!.components(separatedBy: "\t").map { Int($0)! })
	}
}
