import Foundation
import Tools

final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	struct Input {
		let items: [Bool]

		let width: Int
		let height: Int
	}

	private struct Grid {
		let points: Set<[Int]>

		let dimensions: Int

		var mins: [Int]
		var maxes: [Int]

		init(points: Set<[Int]>, dimensions: Int) {
			self.points = points
			self.dimensions = dimensions

			var mins: [Int] = Array(repeating: Int.max, count: dimensions)
			var maxes: [Int] = Array(repeating: Int.min, count: dimensions)

			for point in points {
				for dimension in 0 ..< dimensions {
					mins[dimension] = min(mins[dimension], point[dimension])
					maxes[dimension] = max(maxes[dimension], point[dimension])
				}
			}

			self.mins = mins
			self.maxes = maxes
		}
	}

	private func processGrid(_ grid: Grid) -> Grid {
		let scanPositionVariations = Int(powf(3.0, Float(grid.dimensions)))

		var currentPosition = grid.mins.map { $0 - 1 }
		var ranges: [ClosedRange<Int>] = []

		for dimension in 0 ..< grid.dimensions {
			ranges.append(grid.mins[dimension] - 1 ... grid.maxes[dimension] + 1)
		}

		var newPoints: Set<[Int]> = Set()

		var scanOffset: [Int] = Array(repeating: -1, count: grid.dimensions)
		let centerOffset: [Int] = Array(repeating: 0, count: grid.dimensions)

		var allOffsets: [[Int]] = []

		for _ in 0 ..< scanPositionVariations {
			if scanOffset != centerOffset {
				allOffsets.append(scanOffset)
			}

			for dimension in 0 ..< grid.dimensions {
				scanOffset[dimension] = scanOffset[dimension] + 1

				if scanOffset[dimension] > 1 {
					scanOffset[dimension] = -1
				} else {
					break
				}
			}
		}

		while true {
			var count = 0
			for scanOffset in allOffsets {
				var scanPosition = currentPosition

				for dimension in 0 ..< grid.dimensions {
					scanPosition[dimension] += scanOffset[dimension]
				}

				count += grid.points.contains(scanPosition) ? 1 : 0
			}

			if grid.points.contains(currentPosition) {
				if count == 2 || count == 3 {
					newPoints.insert(currentPosition)
				}
			} else {
				if count == 3 {
					newPoints.insert(currentPosition)
				}
			}

			// increase position
			var isFinished = false
			for dimension in 0 ..< grid.dimensions {
				currentPosition[dimension] += 1

				if ranges[dimension].contains(currentPosition[dimension]) == false {
					currentPosition[dimension] = ranges[dimension].lowerBound

					isFinished = true
				} else {
					isFinished = false

					break
				}
			}

			if isFinished {
				break
			}
		}

		return Grid(points: newPoints, dimensions: grid.dimensions)
	}

	func solvePart1(withInput input: Input) -> Int {
		var points: Set<[Int]> = Set()

		for (index, item) in input.items.enumerated() {
			guard item == true else {
				continue
			}

			let x = index % input.width
			let y = index / input.width

			points.insert([x, 0, y])
		}

		var currentGrid = Grid(points: points, dimensions: 3)

		for _ in 0 ..< 6 {
			currentGrid = processGrid(currentGrid)
		}

		return currentGrid.points.count
	}

	func solvePart2(withInput input: Input) -> Int {
		var points: Set<[Int]> = Set()

		for (index, item) in input.items.enumerated() {
			guard item == true else {
				continue
			}

			let x = index % input.width
			let y = index / input.width

			points.insert([x, 0, y, 0])
		}

		var currentGrid = Grid(points: points, dimensions: 4)

		for _ in 0 ..< 6 {
			currentGrid = processGrid(currentGrid)
		}

		return currentGrid.points.count
	}

	func parseInput(rawString: String) -> Input {
		let grid: [Bool] = rawString.compactMap {
			switch $0 {
			case "#": true
			case ".": false
			default: nil
			}
		}

		let lines = rawString.allLines()

		let width = grid.count / lines.count
		let depth = lines.count

		return .init(items: grid, width: width, height: depth)
	}
}
