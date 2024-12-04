import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	let expectedPart1Result = 2545
	let expectedPart2Result = 0

	private var input: Input!

	private struct Input {
		let map: [Point2D: String]
	}

	func solvePart1() -> Int {
		var counter = 0

		let matchingLetters: [String] = ["M", "A", "S"]
		let possibleDirections: [Direction] = Direction.all

		for (startPoint, startCharacter) in input.map where startCharacter == "X" {
			directionLoop: for direction in possibleDirections {
				var currentPoint = startPoint
				var index = 0

				currentPoint = currentPoint.moved(to: direction)

				while index < 3, let nextCharacter = input.map[currentPoint], nextCharacter == matchingLetters[index] {
					index += 1

					currentPoint = currentPoint.moved(to: direction)
				}

				counter += index == 3 ? 1 : 0
			}
		}

		return counter
	}

	func solvePart2() -> Int {
		let map = input.map

		var counter = 0

		let validCombinations: Set<[String]> = [["M", "S"], ["S", "M"]]

		for (startPoint, startCharacter) in input.map where startCharacter == "A" {
			guard
				let a = map[startPoint.moved(to: .northWest)],
				let b = map[startPoint.moved(to: .northEast)],
				let c = map[startPoint.moved(to: .southWest)],
				let d = map[startPoint.moved(to: .southEast)]
			else {
				continue
			}

			if validCombinations.contains([a, d]), validCombinations.contains([b, c]) {
				counter += 1
			}
		}

		return counter
	}

	func parseInput(rawString: String) {
		var map: [Point2D: String] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, character) in line.enumerated() {
				map[Point2D(x: x, y: y)] = String(character)
			}
		}

		input = .init(map: map)
	}
}
