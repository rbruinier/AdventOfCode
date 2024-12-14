import Foundation
import Tools

/// Part 2 was solved by printing the plants. This shows that the pattern gets stuck after a some generations but the lowest index shifts + 1 each generation.
/// Therefore we can detect the repetion of the pattern, calculate the remaining generations and increase the lowest index with that to get the expected indices
/// at generation 50 billion.
final class Day12Solver: DaySolver {
	let dayNumber: Int = 12

	struct Input {
		let plants: [Bool]
		let instructions: [[Bool]: Bool]
	}

	private func updatePlants(_ plantIndices: [Int], instructions: [[Bool]: Bool]) -> [Int] {
		let lowIndex = plantIndices.min()! - 2
		let maxIndex = plantIndices.max()! + 2

		var newPlantIndices: [Int] = []

		for plantIndex in lowIndex ... maxIndex {
			var pattern: [Bool] = Array(repeating: false, count: 5)

			for (patternIndex, index) in (plantIndex - 2 ... plantIndex + 2).enumerated() {
				pattern[patternIndex] = plantIndices.contains(index)
			}

			let newPlant = instructions[pattern] ?? false

			if newPlant {
				newPlantIndices.append(plantIndex)
			}
		}

		return newPlantIndices
	}

	private func normalizeIndices(_ indices: [Int]) -> [Int] {
		let lowIndex = indices.min()!

		return indices.map { $0 - lowIndex }
	}

	func solvePart1(withInput input: Input) -> Int {
		var currentPlantIndices: [Int] = []

		for (index, plant) in input.plants.enumerated() {
			if plant {
				currentPlantIndices.append(index)
			}
		}

		for _ in 0 ..< 20 {
			currentPlantIndices = updatePlants(currentPlantIndices, instructions: input.instructions)
		}

		return currentPlantIndices.reduce(0, +)
	}

	func solvePart2(withInput input: Input) -> Int {
		var currentPlantIndices: [Int] = []

		for (index, plant) in input.plants.enumerated() {
			if plant {
				currentPlantIndices.append(index)
			}
		}

		var currentNormalizedIndices = normalizeIndices(currentPlantIndices)

		let numberOfGenerations = 50_000_000_000

		for generation in 0 ..< numberOfGenerations {
			currentPlantIndices = updatePlants(currentPlantIndices, instructions: input.instructions)

			let newNormalizedIndices = normalizeIndices(currentPlantIndices)

			if newNormalizedIndices == currentNormalizedIndices {
				// we are stuck in same pattern now, by printing we discovered the + 1 shift for each generation
				let remainingGenerations = numberOfGenerations - generation - 1

				let lowestIndex = currentPlantIndices.min()! + remainingGenerations

				return newNormalizedIndices.map { $0 + lowestIndex }.reduce(0, +)
			}

			currentNormalizedIndices = newNormalizedIndices
		}

		return currentPlantIndices.reduce(0, +)
	}

	func parseInput(rawString: String) -> Input {
		let allLines = rawString.allLines()

		func mapCharToBool(_ char: Character) -> Bool? {
			switch char {
			case "#": true
			case ".": false
			default: nil
			}
		}

		return .init(.init(
			plants: allLines[0].compactMap { mapCharToBool($0) },
			instructions: allLines[1 ..< allLines.count].reduce(into: [[Bool]: Bool]()) { result, line in
				let components: [String] = String(line).components(separatedBy: " => ")

				let key: [Bool] = components[0].compactMap { mapCharToBool($0) }

				result[key] = mapCharToBool(components[1].first!)
			}
		)
		)
	}
}
