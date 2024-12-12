import Foundation
import Tools

final class Day03Solver: DaySolver {
	let dayNumber: Int = 3

	private var input: Input!

	private struct Input {
		let items: [Int]
	}

	func solvePart1() -> Int {
		var gammaRate = 0

		for digitIndex in 0 ..< 12 {
			let bitIsSet: Bool = input.items.reduce(0) { result, value in
				let bitIsSet = (value >> digitIndex) & 1

				return result + bitIsSet
			} > (input.items.count >> 1)

			gammaRate |= (bitIsSet ? 1 : 0) << digitIndex
		}

		let epsilonRate = gammaRate ^ 0b1111_1111_1111

		return gammaRate * epsilonRate
	}

	func solvePart2() -> Int {
		var oxygenGeneratorItems = input.items
		var co2ScrubbingItems = input.items

		for digitIndex in stride(from: 11, to: -1, by: -1) {
			if oxygenGeneratorItems.count > 1 {
				let nrOfBitsSet = oxygenGeneratorItems.reduce(0) { result, value in
					result + ((value >> digitIndex) & 1)
				}

				let nrOfBitsNotSet = oxygenGeneratorItems.count - nrOfBitsSet

				let bitIsSet = nrOfBitsSet >= nrOfBitsNotSet

				oxygenGeneratorItems = oxygenGeneratorItems.filter { value in
					bitIsSet == (((value >> digitIndex) & 1) == 1 ? true : false)
				}
			}

			if co2ScrubbingItems.count > 1 {
				let nrOfBitsSet = co2ScrubbingItems.reduce(0) { result, value in
					result + ((value >> digitIndex) & 1)
				}

				let nrOfBitsNotSet = co2ScrubbingItems.count - nrOfBitsSet

				let bitIsSet = nrOfBitsSet < nrOfBitsNotSet

				co2ScrubbingItems = co2ScrubbingItems.filter { value in
					bitIsSet == (((value >> digitIndex) & 1) == 1 ? true : false)
				}
			}
		}

		let oxygenGeneratorRating = oxygenGeneratorItems.first!
		let co2ScrubberRating = co2ScrubbingItems.first!

		return oxygenGeneratorRating * co2ScrubberRating
	}

	func parseInput(rawString: String) {
		let items = rawString.components(separatedBy: .newlines).compactMap {
			Int($0, radix: 2)
		}

		input = .init(items: items)
	}
}
