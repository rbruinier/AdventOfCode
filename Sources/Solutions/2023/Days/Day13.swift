import Foundation
import Tools

final class Day13Solver: DaySolver {
	let dayNumber: Int = 13

	private var input: Input!

	private struct Input {
		let maps: [Map]
	}

	private struct Map {
		let rocks: Set<Point2D>

		var size: Size {
			.init(width: rocks.map(\.x).max()!, height: rocks.map(\.y).max()!)
		}
	}

	private func scanForReflectionColumn(in map: Map, numberOfDifferences: Int = 0) -> Int? {
		let size = map.size

		centerXLoop: for centerX in 0 ..< size.width {
			let maxOffset = min(centerX, size.width - centerX - 1)

			var sumOfDifferences = 0

			for offsetX in 0 ... maxOffset {
				let aX = centerX - offsetX
				let bX = centerX + offsetX + 1

				let a = Set(map.rocks.filter { $0.x == aX }.map(\.y))
				let b = Set(map.rocks.filter { $0.x == bX }.map(\.y))

				sumOfDifferences += a.symmetricDifference(b).count

				if sumOfDifferences > numberOfDifferences {
					continue centerXLoop
				}
			}

			if sumOfDifferences == numberOfDifferences {
				return centerX
			}
		}

		return nil
	}

	private func scanForReflectionRow(in map: Map, numberOfDifferences: Int = 0) -> Int? {
		let size = map.size

		centerYLoop: for centerY in 0 ..< size.height {
			let maxOffset = min(centerY, size.height - centerY - 1)

			var sumOfDifferences = 0

			for offsetY in 0 ... maxOffset {
				let aY = centerY - offsetY
				let bY = centerY + offsetY + 1

				let a = Set(map.rocks.filter { $0.y == aY }.map(\.x))
				let b = Set(map.rocks.filter { $0.y == bY }.map(\.x))

				sumOfDifferences += a.symmetricDifference(b).count

				if sumOfDifferences > numberOfDifferences {
					continue centerYLoop
				}
			}

			if sumOfDifferences == numberOfDifferences {
				return centerY
			}
		}

		return nil
	}

	func solvePart1() -> Int {
		input.maps.reduce(into: 0) { result, map in
			if let row = scanForReflectionRow(in: map) {
				result += 100 * (row + 1)
			}

			if let column = scanForReflectionColumn(in: map) {
				result += column + 1
			}
		}
	}

	func solvePart2() -> Int {
		input.maps.reduce(into: 0) { result, map in
			if let row = scanForReflectionRow(in: map, numberOfDifferences: 1) {
				result += 100 * (row + 1)
			}

			if let column = scanForReflectionColumn(in: map, numberOfDifferences: 1) {
				result += column + 1
			}
		}
	}

	func parseInput(rawString: String) {
		var rocks: Set<Point2D> = []
		var maps: [Map] = []
		var y = 0

		for line in rawString.allLines(includeEmpty: true) {
			if line.isEmpty {
				maps.append(.init(rocks: rocks))

				rocks.removeAll()
				y = 0

				continue
			}

			for (x, character) in line.enumerated() {
				let point = Point2D(x: x, y: y)

				switch character {
				case ".": break
				case "#": rocks.insert(point)
				default: preconditionFailure()
				}
			}

			y += 1
		}

		input = .init(maps: maps)
	}
}
