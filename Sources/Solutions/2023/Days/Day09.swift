import Foundation
import Tools

/// Super naive implementation but works fine. Really was expecting a harder problem for part 2.
final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	struct Input {
		let sequences: [[Int]]
	}

	private func reduceSequence(_ sequence: [Int]) -> [Int] {
		sequence.dropFirst().enumerated().map { $0.element - sequence[$0.offset] }
	}

	private func createLayers(_ sequence: [Int]) -> [[Int]] {
		var layers: [[Int]] = [sequence]

		while Set(layers.last!).count > 1 {
			layers.append(reduceSequence(layers.last!))
		}

		return layers
	}

	func solvePart1(withInput input: Input) -> Int {
		input.sequences.reduce(0) { result, sequence in
			let layers = createLayers(sequence)

			return result + layers.compactMap(\.last).reduce(0, +)
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		input.sequences.reduce(0) { result, sequence in
			let layers = createLayers(sequence)

			return result + layers.reversed().compactMap(\.first).reduce(0) { $1 - $0 }
		}
	}

	func parseInput(rawString: String) -> Input {
		return .init(sequences: rawString.allLines().map { $0.components(separatedBy: " ").compactMap(Int.init) })
	}
}
