import Foundation
import Tools

final class Day11Solver: DaySolver {
	let dayNumber: Int = 11

	private var input: Input!

	private struct Input {
		let galaxies: Set<Point2D>
	}

	func expandColumns(in galaxies: Set<Point2D>, factor: Int) -> Set<Point2D> {
		var newGalaxies: Set<Point2D> = []

		let maxX = galaxies.map(\.x).max()!

		var newX = 0
		for x in 0 ... maxX {
			let existingGalaxiesOnColumn = galaxies.filter { $0.x == x }

			if existingGalaxiesOnColumn.isEmpty {
				newX += factor
			} else {
				newGalaxies = newGalaxies.union(existingGalaxiesOnColumn.map { .init(x: newX, y: $0.y) })

				newX += 1
			}
		}

		return newGalaxies
	}

	func expandRows(in galaxies: Set<Point2D>, factor: Int) -> Set<Point2D> {
		var newGalaxies: Set<Point2D> = []

		let maxY = galaxies.map(\.y).max()!

		var newY = 0
		for y in 0 ... maxY {
			let existingGalaxiesOnRow = galaxies.filter { $0.y == y }

			if existingGalaxiesOnRow.isEmpty {
				newY += factor
			} else {
				newGalaxies = newGalaxies.union(existingGalaxiesOnRow.map { .init(x: $0.x, y: newY) })

				newY += 1
			}
		}

		return newGalaxies
	}

	private func calculateTotalDistance(with originalGalaxies: Set<Point2D>, factor: Int) -> Int {
		var expandedGalaxies = originalGalaxies

		expandedGalaxies = expandColumns(in: expandedGalaxies, factor: factor)
		expandedGalaxies = expandRows(in: expandedGalaxies, factor: factor)

		let galaxies = Array(expandedGalaxies)

		var sum = 0
		for i in 0 ..< galaxies.count {
			for j in i + 1 ..< galaxies.count {
				let distance = galaxies[i].manhattanDistance(from: galaxies[j])

				sum += distance
			}
		}

		return sum
	}

	func solvePart1() -> Int {
		calculateTotalDistance(with: input.galaxies, factor: 2)
	}

	func solvePart2() -> Int {
		calculateTotalDistance(with: input.galaxies, factor: 1_000_000)
	}

	func parseInput(rawString: String) {
		var galaxies: Set<Point2D> = []

		rawString.allLines().enumerated().forEach { y, line in
			line.enumerated().forEach { x, character in
				let point = Point2D(x: x, y: y)

				switch character {
				case ".": break
				case "#": galaxies.insert(point)
				default: preconditionFailure()
				}
			}
		}

		input = .init(galaxies: galaxies)
	}
}
