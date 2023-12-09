import Foundation
import Tools

/// Super naive implementation but works fine. Really was expecting a harder problem for part 2.
final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	let expectedPart1Result = 1938800261
	let expectedPart2Result = 1112

	private var input: Input!

	private struct Input {
		let sequences: [[Int]]
	}

	private func reduceSequence(_ sequence: [Int]) -> [Int] {
		var newSequence: [Int] = []

		for index in 0 ..< sequence.count - 1 {
			newSequence.append(sequence[index + 1] - sequence[index])
		}

		return newSequence
	}

	private func createLayers(_ sequence: [Int]) -> [[Int]] {
		var newSequence = sequence
		var layers: [[Int]] = [newSequence]

		while true {
			newSequence = reduceSequence(newSequence)

			layers.append(newSequence)

			if Set(newSequence).count == 1 {
				return layers
			}
		}
	}

	func solvePart1() -> Int {
		input.sequences.reduce(0) { result, sequence in
			var layers = createLayers(sequence)

			return result + layers.compactMap(\.last).reduce(0, +)
		}
	}

	func solvePart2() -> Int {
		input.sequences.reduce(0) { result, sequence in
			var layers = createLayers(sequence)

			for index in (1 ..< layers.count).reversed() {
				layers[index - 1].insert(layers[index - 1].first! - layers[index].first!, at: 0)
			}

			return result + layers.first!.first!
		}
	}

	func parseInput(rawString: String) {
		input = .init(sequences: rawString.allLines().map { $0.components(separatedBy: " ").compactMap(Int.init) })
	}
}
