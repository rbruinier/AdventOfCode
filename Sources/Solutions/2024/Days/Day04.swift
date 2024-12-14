import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	struct Input {
		let map: [Point2D: String]
	}

	func solvePart1(withInput input: Input) -> Int {
		var counter = 0

		let matchingCharacters: [String] = ["M", "A", "S"]

		for (startPoint, startCharacter) in input.map where startCharacter == "X" {
			directionLoop: for direction in Direction.all {
				var currentPoint = startPoint.moved(to: direction)
				var index = 0

				while index < 3, let nextCharacter = input.map[currentPoint], nextCharacter == matchingCharacters[index] {
					index += 1

					currentPoint.move(to: direction)
				}

				counter += index == 3 ? 1 : 0
			}
		}

		return counter
	}

	func solvePart2(withInput input: Input) -> Int {
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

	func parseInput(rawString: String) -> Input {
		var map: [Point2D: String] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, character) in line.enumerated() {
				map[Point2D(x: x, y: y)] = String(character)
			}
		}

		return .init(map: map)
	}
}
