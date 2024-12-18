import Foundation
import Tools

final class Day13Solver: DaySolver {
	let dayNumber: Int = 13

	struct Input {
		let pairs: [String: [Pair]]
	}

	struct Pair {
		let a: String
		let b: String

		let score: Int
	}

	private func calculateHappiness(seating: [String], pairs: [String: [Pair]]) -> Int {
		var score = 0

		for (index, name) in seating.enumerated() {
			let scoring = pairs[name]!

			let previousIndex = (index >= 1) ? index - 1 : seating.count - 1
			let nextIndex = (index + 1) % seating.count

			let previousName = seating[previousIndex]
			let nextName = seating[nextIndex]

			let previousScore = scoring.first { $0.b == previousName }!.score
			let nextScore = scoring.first { $0.b == nextName }!.score

			score += previousScore + nextScore
		}

		return score
	}

	func solvePart1(withInput input: Input) -> Int {
		let pairs = input.pairs
		let names: [String] = Array(pairs.keys)

		let allCombinations = names.permutations

		var bestScore = Int.min

		for seating in allCombinations {
			bestScore = max(bestScore, calculateHappiness(seating: seating, pairs: pairs))
		}

		return bestScore
	}

	func solvePart2(withInput input: Input) -> Int {
		var pairs = input.pairs
		var names: [String] = Array(pairs.keys)

		let newName = "Robert"

		pairs[newName] = names.reduce(into: []) { result, name in
			result.append(.init(a: newName, b: name, score: 0))
		}

		for name in names {
			pairs[name]!.append(.init(a: name, b: newName, score: 0))
		}

		names.append(newName)

		let allCombinations = names.permutations

		var bestScore = Int.min

		for seating in allCombinations {
			bestScore = max(bestScore, calculateHappiness(seating: seating, pairs: pairs))
		}

		return bestScore
	}

	func parseInput(rawString: String) -> Input {
		var pairs: [String: [Pair]] = [:]

		rawString.allLines().forEach { line in
			guard let parameters = line.getCapturedValues(pattern: #"([a-zA-Z]*) would ([a-zA-Z]*) ([0-9]*) happiness units by sitting next to ([a-zA-Z]*)"#) else {
				fatalError()
			}

			let a = parameters[0]
			let b = parameters[3]

			let score = Int(parameters[2])!

			let sign: Int = parameters[1] == "gain" ? 1 : -1

			pairs[a, default: []] += [.init(a: a, b: b, score: sign * score)]
		}

		return .init(pairs: pairs)
	}
}
