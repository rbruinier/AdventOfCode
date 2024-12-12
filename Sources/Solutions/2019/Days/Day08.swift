import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	private var input: Input!

	private struct Input {
		let layers: [[Int]]

		let width: Int
		let height: Int
	}

	func solvePart1() -> Int {
		var minLayer: [Int] = input.layers.first!
		var minNumberOfZeros = minLayer.filter { $0 == 0 }.count

		for layer in input.layers[1 ..< input.layers.count] {
			let numberOfZeros = layer.filter { $0 == 0 }.count

			if numberOfZeros < minNumberOfZeros {
				minNumberOfZeros = numberOfZeros
				minLayer = layer
			}
		}

		return minLayer.filter { $0 == 1 }.count * minLayer.filter { $0 == 2 }.count
	}

	func solvePart2() -> String {
		let transparent = 2

		var finalPixels: [Int] = Array(repeating: transparent, count: input.width * input.height)

		for layer in input.layers {
			for pixelIndex in 0 ..< input.width * input.height {
				let existingPixel = finalPixels[pixelIndex]

				guard existingPixel == transparent else {
					continue
				}

				finalPixels[pixelIndex] = layer[pixelIndex]
			}
		}

		var index = 0
		for _ in 0 ..< input.height {
			var line = ""

			for _ in 0 ..< input.width {
				line += finalPixels[index] >= 1 ? " # " : "   "

				index += 1
			}

			//            print(line)
		}

		return "AURCY"
	}

	func parseInput(rawString: String) {
		let pixels = rawString.compactMap { Int(String($0)) }

		let layerSize = 25 * 6

		assert((pixels.count % layerSize) == 0)

		var layers: [[Int]] = []

		let nrOfLayers = pixels.count / layerSize
		for layer in 0 ..< nrOfLayers {
			layers.append(Array(pixels[(layer * layerSize) ..< ((layer + 1) * layerSize)]))
		}

		input = .init(layers: layers, width: 25, height: 6)
	}
}
