import Foundation
import Tools

final class Day20Solver: DaySolver {
	let dayNumber: Int = 20

	struct Input {
		let numberOfPresents = 34_000_000
	}

	func solvePart1(withInput input: Input) -> Int {
		// I first implemented a brute force algo and looked at the sequence and googled the sequence and found this: http://sequencedb.net/s/A000203
		//
		// Then I looked for an efficient way to calculate the div sum

		var house = 1
		while true {
			let presents = Math.divisorSigma(n: house) * 10

			if presents >= input.numberOfPresents {
				return house
			}

			house += 1
		}

		fatalError()
	}

	func solvePart2(withInput input: Input) -> Int {
		var house = 1
		while true {
			var presents = 0

			// adjusted divisor sigma function
			for i in 1 ... max(1, Int(Double(house).squareRoot())) where house % i == 0 {
				if i == house / i {
					if house / i <= 50 {
						presents += i
					}
				} else {
					if i <= 50 {
						presents += i + (house / i)
					}
				}
			}

			presents *= 11

			if presents >= input.numberOfPresents {
				return house
			}

			house += 1
		}

		fatalError()
	}

	func parseInput(rawString: String) -> Input {
		return .init()
	}
}
