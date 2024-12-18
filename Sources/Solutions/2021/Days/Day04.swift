import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	struct Input {
		let drawnNumbers: [Int]
		let boards: [Board]
	}

	struct Board {
		struct Item {
			var value: Int
			var checked: Bool = false
		}

		var items: [Item]

		init(numbers: [Int]) {
			items = numbers.map {
				.init(value: $0)
			}
		}

		var isCompleted: Bool {
			for row in 0 ..< 5 {
				if items[row * 5 ..< ((row + 1) * 5)].allSatisfy({ $0.checked == true }) {
					return true
				}
			}

			for column in 0 ..< 5 {
				var checkedCount = 0

				for row in 0 ..< 5 {
					checkedCount += items[(row * 5) + column].checked ? 1 : 0
				}

				if checkedCount == 5 {
					return true
				}
			}

			return false
		}

		mutating func mark(number: Int) {
			for index in 0 ..< 25 {
				if items[index].value == number {
					items[index].checked = true

					return
				}
			}
		}

		var score: Int {
			items.reduce(0) { result, item in
				result + (item.checked ? 0 : item.value)
			}
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		var boards = input.boards

		for number in input.drawnNumbers {
			for boardIndex in 0 ..< boards.count {
				boards[boardIndex].mark(number: number)
			}

			if let completedBoard = boards.first(where: { $0.isCompleted }) {
				return number * completedBoard.score
			}
		}

		return 0
	}

	func solvePart2(withInput input: Input) -> Int {
		var boards = input.boards

		var lastWinningScore = 0

		for number in input.drawnNumbers {
			for boardIndex in 0 ..< boards.count {
				boards[boardIndex].mark(number: number)
			}

			boards
				.filter(\.isCompleted)
				.forEach { lastWinningScore = number * $0.score
				}

			boards.removeAll { $0.isCompleted }
		}

		return lastWinningScore
	}

	func parseInput(rawString: String) -> Input {
		let index = rawString.firstIndex(of: "\n")!

		let drawnNumbers = String(rawString[rawString.startIndex ..< index])
			.components(separatedBy: ",")
			.compactMap { Int($0) }

		let rawBoardNumbers = String(rawString[index ..< rawString.endIndex])
			.components(separatedBy: CharacterSet.whitespacesAndNewlines)
			.compactMap { Int($0) }

		var boards: [Board] = []

		for startIndex in stride(from: 0, to: rawBoardNumbers.count, by: 25) {
			let board: Board = .init(numbers: Array(rawBoardNumbers[startIndex ..< (startIndex + 25)]))

			boards.append(board)
		}

		return .init(drawnNumbers: drawnNumbers, boards: boards)
	}
}
