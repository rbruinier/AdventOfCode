import Foundation
import Tools

final class Day14Solver: DaySolver {
	let dayNumber: Int = 14

	struct Input {
		let polymerTemplate: [Character]

		let insertionRules: [InsertionRule]
	}

	struct InsertionRule {
		let elements: [Character]
		let result: Character
	}

	private struct Pair: Equatable, Hashable {
		let a: Character
		let b: Character
	}

	private func solveForSteps(_ steps: Int, polymerTemplate: [Character], insertionRules: [InsertionRule]) -> Int {
		var currentPairs: [Pair: Int] = [:]
		var letterCount: [Character: Int] = [polymerTemplate[0]: 1]

		for characterIndex in 0 ..< polymerTemplate.count - 1 {
			let a = polymerTemplate[characterIndex]
			let b = polymerTemplate[characterIndex + 1]

			let pair = Pair(a: a, b: b)

			currentPairs[pair, default: 0] += 1

			letterCount[b, default: 0] += 1
		}

		let insertionRules: [Pair: [Pair]] = insertionRules.reduce(into: [Pair: [Pair]]()) { result, item in
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

	func solvePart1(withInput input: Input) -> Int {
		solveForSteps(10, polymerTemplate: input.polymerTemplate, insertionRules: input.insertionRules)
	}

	func solvePart2(withInput input: Input) -> Int {
		solveForSteps(40, polymerTemplate: input.polymerTemplate, insertionRules: input.insertionRules)
	}

	func parseInput(rawString: String) -> Input {
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

		return .init(polymerTemplate: polymerTemplate, insertionRules: rules)
	}
}
