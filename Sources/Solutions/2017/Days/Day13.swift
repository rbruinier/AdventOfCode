import Foundation
import Tools

final class Day13Solver: DaySolver {
	let dayNumber: Int = 13

	private var input: Input!

	private struct Input {
		let layers: [Int: Int]
	}

	@inline(__always)
	private func positionOfScannerIsZero(timer: Int, depth: Int) -> Bool {
		let cycleSize = (depth - 1) * 2

		return timer % cycleSize == 0
	}

	private func calculateSeverity(startTime: Int, layers: [Int: Int]) -> (severity: Int, caught: Bool) {
		let nrOfLayers = layers.keys.max()! + 1

		var gotCaught = false

		var result = 0
		for layer in 0 ..< nrOfLayers {
			guard let depth = layers[layer] else {
				continue
			}

			if positionOfScannerIsZero(timer: layer + startTime, depth: depth) {
				result += layer * depth
				gotCaught = true
			}
		}

		return (severity: result, caught: gotCaught)
	}

	func solvePart1() -> Int {
		calculateSeverity(startTime: 4, layers: input.layers).severity
	}

	func solvePart2() -> Int {
		for delay in 10 ..< 1_000_000_000 {
			if calculateSeverity(startTime: delay, layers: input.layers).caught == false {
				return delay
			}
		}

		fatalError()
	}

	func parseInput(rawString: String) {
		input = .init(layers: rawString.allLines().reduce(into: [Int: Int]()) { result, line in
			let components = line.components(separatedBy: ": ")

			result[Int(components[0])!] = Int(components[1])!
		})
	}
}
