import Foundation
import Tools

final class Day23Solver: DaySolver {
	let dayNumber: Int = 23

	struct Input {
		let cups: [Int]
	}

	private func playRoundLinkedList(cups: LoopedLinkedListSet<Int>, currentCupValue: inout Int, maxCupValue: Int, moveID: Int) {
		let currentCupNode = cups.findNode(for: currentCupValue)!

		let nodes: [LoopedLinkedListSet<Int>.Node] = [
			cups.removeNextNode(of: currentCupNode),
			cups.removeNextNode(of: currentCupNode),
			cups.removeNextNode(of: currentCupNode),
		]

		var newCupValue = currentCupValue
		var newCupNode: LoopedLinkedListSet<Int>.Node!

		while true {
			newCupValue -= 1

			if newCupValue <= 0 {
				newCupValue = maxCupValue
			}

			if let cupsNewCupNode = cups.findNode(for: newCupValue) {
				newCupNode = cupsNewCupNode

				break
			}
		}

		cups.insertNodes(nodes, after: newCupNode)

		currentCupValue = currentCupNode.next!.value
	}

	private func play(moves: Int, with cups: LoopedLinkedListSet<Int>, originalCups: [Int], maxValue: Int) -> Int {
		var currentCupValue = originalCups.first!

		for moveID in 1 ... moves {
			playRoundLinkedList(cups: cups, currentCupValue: &currentCupValue, maxCupValue: maxValue, moveID: moveID)
		}

		var currentNode = cups.findNode(for: 1)!

		var finalResult = 0

		for _ in 0 ..< originalCups.count - 1 {
			currentNode = currentNode.next!

			finalResult *= 10
			finalResult += currentNode.value
		}

		return finalResult
	}

	func solvePart1(withInput input: Input) -> Int {
		let cups = LoopedLinkedListSet<Int>(values: input.cups)

		return play(moves: 100, with: cups, originalCups: input.cups, maxValue: 9)
	}

	func solvePart2(withInput input: Input) -> Int {
		var cupValues = input.cups

		for index in (input.cups.count + 1) ... 1_000_000 {
			cupValues.append(index)
		}

		let cups = LoopedLinkedListSet(values: cupValues)

		_ = play(moves: 10_000_000, with: cups, originalCups: input.cups, maxValue: 1_000_000)

		let currentNode = cups.findNode(for: 1)!

		return currentNode.next!.value * currentNode.next!.next!.value
	}

	func parseInput(rawString: String) -> Input {
		return .init(cups: [2, 8, 4, 5, 7, 3, 9, 6, 1])
	}
}
