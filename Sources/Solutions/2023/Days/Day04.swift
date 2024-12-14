import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	struct Input {
		let cards: [Card]
	}

	struct Card {
		let winningNumbers: Set<Int>
		let myNumbers: Set<Int>

		let numberOfMatchingNumbers: Int
		let score: Int

		init(winningNumbers: Set<Int>, myNumbers: Set<Int>) {
			self.winningNumbers = winningNumbers
			self.myNumbers = myNumbers

			(numberOfMatchingNumbers, score) = Self.calculateNumberOfMatchingNumbersAndScore(withWinningNumbers: winningNumbers, myNumbers: myNumbers)
		}

		static func calculateNumberOfMatchingNumbersAndScore(withWinningNumbers winningNumbers: Set<Int>, myNumbers: Set<Int>) -> (Int, Int) {
			let numberOfMatchingNumbers = winningNumbers.intersection(myNumbers).count

			// negative number shifting appears to work 😅
			let totalScore = 2 << (numberOfMatchingNumbers - 2)

			return (numberOfMatchingNumbers, totalScore)
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		input.cards.map(\.score).reduce(0, +)
	}

	func solvePart2(withInput input: Input) -> Int {
		var copiesPerCard: [Int: Int] = [:]

		for index in 0 ..< input.cards.count {
			copiesPerCard[index] = 1
		}

		for (index, card) in input.cards.enumerated() {
			let numberOfMatchingNumbers = card.numberOfMatchingNumbers

			if numberOfMatchingNumbers > 0 {
				for copyIndex in min(index + 1, input.cards.count - 1) ... min(input.cards.count - 1, index + numberOfMatchingNumbers) {
					copiesPerCard[copyIndex]! += copiesPerCard[index]!
				}
			}
		}

		return copiesPerCard.values.reduce(0, +)
	}

	func parseInput(rawString: String) -> Input {
		let cards: [Card] = rawString.allLines().map { line in
			let numberComponents = line.components(separatedBy: ": ")[1].components(separatedBy: " | ")

			return Card(
				winningNumbers: Set(numberComponents[0].components(separatedBy: " ").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }),
				myNumbers: Set(numberComponents[1].components(separatedBy: " ").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) })
			)
		}

		return .init(cards: cards)
	}
}
