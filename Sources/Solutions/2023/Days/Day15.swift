import Foundation
import Tools

final class Day15Solver: DaySolver {
	let dayNumber: Int = 15

	private var input: Input!

	private struct Input {
		let steps: [String]
	}

	private func hash(for string: AsciiString) -> Int {
		string.reduce(into: 0) { result, character in
			result = ((result + Int(character)) * 17) % 256
		}
	}

	func solvePart1() -> Int {
		input.steps.reduce(into: 0) { result, step in
			result += hash(for: AsciiString(string: step))
		}
	}

	func solvePart2() -> Int {
		struct Lens {
			let label: String
			let focalLength: Int
		}

		var boxes: [Int: [Lens]] = .init(minimumCapacity: 256)

		for step in input.steps {
			if step.hasSuffix("-") {
				let label = String(step.dropLast())
				let boxID = hash(for: AsciiString(string: label))

				boxes[boxID] = boxes[boxID, default: []].filter { $0.label != label }
			} else {
				let components = step.components(separatedBy: "=")

				let label = components[0]
				let focalLength = Int(components[1])!
				let boxID = hash(for: AsciiString(string: label))

				let lens = Lens(label: components[0], focalLength: focalLength)

				if let existingIndex = boxes[boxID, default: []].firstIndex(where: { $0.label == label }) {
					var newLenses = boxes[boxID]!

					newLenses.replaceSubrange(existingIndex ... existingIndex, with: [lens])

					boxes[boxID] = newLenses
				} else {
					boxes[boxID] = boxes[boxID, default: []] + [lens]
				}
			}
		}

		var result = 0
		for (boxID, box) in boxes {
			for (lensID, lens) in box.enumerated() {
				result += (1 + boxID) * (1 + lensID) * lens.focalLength
			}
		}

		return result
	}

	func parseInput(rawString: String) {
		input = .init(steps: rawString.components(separatedBy: ",").map { rawStep in
			rawStep.trimmingCharacters(in: .whitespacesAndNewlines)
		})
	}
}
