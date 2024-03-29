import Foundation
import Tools

final class Day14Solver: DaySolver {
	let dayNumber: Int = 14

	let expectedPart1Result = 3009
	let expectedPart2Result = 3459822539451

	private var input: Input!

	private struct Input {
		let polymerTemplate: [Character]

		let insertionRules: [InsertionRule]
	}

	private struct InsertionRule {
		let elements: [Character]
		let result: Character
	}

	private struct Pair: Equatable, Hashable {
		let a: Character
		let b: Character
	}

	private func solveForSteps(_ steps: Int) -> Int {
		var currentPairs: [Pair: Int] = [:]
		var letterCount: [Character: Int] = [input.polymerTemplate[0]: 1]

		for characterIndex in 0 ..< input.polymerTemplate.count - 1 {
			let a = input.polymerTemplate[characterIndex]
			let b = input.polymerTemplate[characterIndex + 1]

			let pair = Pair(a: a, b: b)

			currentPairs[pair, default: 0] += 1

			letterCount[b, default: 0] += 1
		}

		let insertionRules: [Pair: [Pair]] = input.insertionRules.reduce(into: [Pair: [Pair]]()) { result, item in
			result[Pair(a: item.elements[0], b: item.elements[1])] = [
				Pair(a: item.elements[0], b: item.result),
				Pair(a: item.result, b: item.elements[1]),
			]
		}

		for _ in 0 ..< steps {
			var newPairs: [Pair: Int] = [:]

			for (pair, count) in currentPairs {
				if let rulesNewPairs = insertionRules[pair] {
					for newPair in rulesNewPairs {
						newPairs[newPair, default: 0] += count
					}

					letterCount[rulesNewPairs[0].b, default: 0] += count
				} else {
					newPairs[pair, default: 0] += count
				}
			}

			currentPairs = newPairs
		}

		let highestElementOccurence = letterCount.values.max()!
		let lowestElementOccurence = letterCount.values.min()!

		return highestElementOccurence - lowestElementOccurence
	}

	func solvePart1() -> Int {
		solveForSteps(10)
	}

	func solvePart2() -> Int {
		solveForSteps(40)
	}

	func parseInput(rawString: String) {
		let rawLines = rawString
			.components(separatedBy: CharacterSet.newlines)
			.compactMap { $0.isEmpty == false ? $0 : nil }

		let polymerTemplate = rawLines[0].map { $0 }

		var rules: [InsertionRule] = []

		for index in 1 ..< rawLines.count {
			let rawLine = rawLines[index]

			let components = rawLine.description.components(separatedBy: " -> ")

			let elements = components[0].map { $0 }
			let result = components[1].first!

			rules.append(InsertionRule(elements: elements, result: result))
		}

		input = .init(polymerTemplate: polymerTemplate, insertionRules: rules)
	}
}
