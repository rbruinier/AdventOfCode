import Foundation
import Tools

final class Day14Solver: DaySolver {
	let dayNumber: Int = 14

	struct Input {
		let value: Int
	}

	func solvePart1(withInput input: Input) -> String {
		var recipeScores: [Int] = [3, 7]

		var index1 = 0
		var index2 = 1

		let recipeCount = input.value

		while recipeScores.count < recipeCount + 10 {
			// combined code
			let score = recipeScores[index1] + recipeScores[index2]

			if score < 10 {
				recipeScores.append(score)
			} else {
				recipeScores.append(1)
				recipeScores.append(score - 10)
			}

			// move forward
			index1 = (index1 + 1 + recipeScores[index1]) % recipeScores.count
			index2 = (index2 + 1 + recipeScores[index2]) % recipeScores.count
		}

		return recipeScores[recipeCount ..< recipeCount + 10].map { String($0) }.joined()
	}

	func solvePart2(withInput input: Input) -> Int {
		var recipeScores: [Int] = [3, 7]

		recipeScores.reserveCapacity(1_000_000_000)

		var index1 = 0
		var index2 = 1

		let searchPattern: [Int] = String(input.value).map { Int(String($0))! }

		while true {
			// combined code
			let score = recipeScores[index1] + recipeScores[index2]

			if score < 10 {
				recipeScores.append(score)
			} else {
				recipeScores.append(1)
				recipeScores.append(score - 10)
			}

			if recipeScores.count >= searchPattern.count {
				let currentDigits = Array(recipeScores[(recipeScores.count - searchPattern.count) ..< recipeScores.count])

				if searchPattern == currentDigits {
					return recipeScores.count - searchPattern.count
				}

				if score >= 10, recipeScores.count > searchPattern.count {
					let currentDigits = Array(recipeScores[(recipeScores.count - searchPattern.count - 1) ..< (recipeScores.count - 1)])

					if searchPattern == currentDigits {
						return recipeScores.count - searchPattern.count - 1
					}
				}
			}

			// move forward
			index1 = (index1 + 1 + recipeScores[index1]) % recipeScores.count
			index2 = (index2 + 1 + recipeScores[index2]) % recipeScores.count
		}
	}

	func parseInput(rawString: String) -> Input {
		return .init(value: 920_831)
	}
}
