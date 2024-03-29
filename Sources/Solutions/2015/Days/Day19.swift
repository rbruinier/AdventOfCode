import Foundation
import Tools

final class Day19Solver: DaySolver {
	let dayNumber: Int = 19

	let expectedPart1Result = 509
	let expectedPart2Result = 195

	private var input: Input!

	private struct Input {
		let replacements: [String: [String]]

		let molecule: String
	}

	func reduceToE(current original: String, reverseMatches: [String: String], replacements: [String]) -> Int {
		var current = original
		var shuffableReplacements = replacements
		var steps = 0

		while current != "e" {
			let startingString = current

			for replacement in shuffableReplacements {
				if let range = current.range(of: replacement) {
					current = current.replacingOccurrences(of: replacement, with: reverseMatches[replacement]!, options: [], range: range)

					steps += 1
				}
			}

			if current == startingString {
				current = original
				steps = 0
				shuffableReplacements.shuffle()
			}
		}

		// always results in 195 which is the correct answer, so no need to have an algorithm finding the smallest steps

		return steps
	}

	func solvePart1() -> Int {
		var combinations: Set<String> = []

		for (original, replacements) in input.replacements {
			let ranges = input.molecule.ranges(of: original)

			for replacement in replacements {
				for range in ranges {
					let alternative = input.molecule.replacingOccurrences(of: original, with: replacement, options: [], range: range)

					combinations.insert(alternative)
				}
			}
		}

		return combinations.count
	}

	func solvePart2() -> Int {
		var reverseMatches: [String: String] = [:]

		for (original, replacements) in input.replacements {
			for replacement in replacements {
				if reverseMatches.keys.contains(replacement) {
					fatalError()
				}

				reverseMatches[replacement] = original
			}
		}

		let replacements = Array(reverseMatches.keys)

		return reduceToE(current: input.molecule, reverseMatches: reverseMatches, replacements: replacements)
	}

	func parseInput(rawString: String) {
		var lines = rawString.allLines()

		let molecule = lines.removeLast()

		var replacements: [String: [String]] = [:]

		lines.forEach { line in
			let parts = line.components(separatedBy: " => ")

			replacements[parts[0], default: []].append(parts[1])
		}

		input = .init(replacements: replacements, molecule: molecule)
	}
}
