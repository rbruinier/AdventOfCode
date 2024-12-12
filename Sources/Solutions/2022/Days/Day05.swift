import Foundation
import Tools

final class Day05Solver: DaySolver {
	let dayNumber: Int = 5

	private var input: Input!

	private struct Input {
		let stacks: [[String]]
		let moves: [Move]
	}

	struct Move {
		let quantity: Int
		let fromStack: Int
		let toStack: Int
	}

	init() {}

	func solvePart1() -> String {
		var stacks = input.stacks

		for move in input.moves {
			for _ in 0 ..< move.quantity {
				let item = stacks[move.fromStack].removeLast()

				stacks[move.toStack].append(item)
			}
		}

		return stacks.reduce("") { $0 + ($1.last ?? "") }
	}

	func solvePart2() -> String {
		var stacks = input.stacks

		for move in input.moves {
			stacks[move.toStack].append(contentsOf: stacks[move.fromStack].suffix(move.quantity))
			stacks[move.fromStack].removeLast(move.quantity)
		}

		return stacks.reduce("") { $0 + ($1.last ?? "") }
	}

	func parseInput(rawString: String) {
		let numberOfStacks = 9

		var stacks: [[String]] = Array(repeating: [], count: numberOfStacks)
		var moves: [Move] = []

		var parsingStacks = true

		for line in rawString.allLines(includeEmpty: true) {
			if line.isEmpty {
				parsingStacks = false

				continue
			}

			if parsingStacks {
				for stackIndex in 0 ..< numberOfStacks {
					let offset = (stackIndex * 4) + 1

					if offset >= line.count || line[offset] == " " {
						continue
					}

					stacks[stackIndex].insert(line[offset], at: 0)
				}
			} else {
				let values = line.getCapturedValues(pattern: #"move ([0-9]*) from ([0-9]*) to ([0-9]*)"#)!

				moves.append(.init(quantity: Int(values[0])!, fromStack: Int(values[1])! - 1, toStack: Int(values[2])! - 1))
			}
		}

		input = .init(stacks: stacks, moves: moves)
	}
}
