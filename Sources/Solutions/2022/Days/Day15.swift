import Foundation
import Tools

final class Day15Solver: DaySolver {
	let dayNumber: Int = 15

	private var input: Input!

	private struct Input {
		let sensors: [Sensor]
	}

	private struct Sensor {
		let position: Point2D
		let closestBeaconPosition: Point2D

		let manhattanDistance: Int

		init(position: Point2D, closestBeaconPosition: Point2D) {
			self.position = position
			self.closestBeaconPosition = closestBeaconPosition

			manhattanDistance = position.manhattanDistance(from: closestBeaconPosition)
		}

		func xBoundariesForY(_ y: Int) -> ClosedRange<Int>? {
			let yOffset = abs(y - position.y)

			guard yOffset <= manhattanDistance else {
				return nil
			}

			let xDistance = manhattanDistance - yOffset

			return (position.x - xDistance) ... (position.x + xDistance)
		}
	}

	init() {}

	private func mergedBoundariesForY(_ y: Int, sensors: [Sensor]) -> [ClosedRange<Int>] {
		let boundaries = sensors.compactMap { $0.xBoundariesForY(y) }.sorted(by: { $0.lowerBound < $1.lowerBound })

		var mergedBoundaries: [ClosedRange<Int>] = []

		var index = 0
		while var currentBoundary = boundaries[safe: index] {
			while true {
				index += 1

				if let nextBoundary = boundaries[safe: index], currentBoundary.overlaps(nextBoundary.lowerBound - 1 ... nextBoundary.upperBound) {
					currentBoundary = currentBoundary.lowerBound ... max(nextBoundary.upperBound, currentBoundary.upperBound)
				} else {
					break
				}
			}

			mergedBoundaries.append(currentBoundary)
		}

		return mergedBoundaries
	}

	func solvePart1() -> Int {
		let inspectY = 2_000_000

		let mergedBoundaries = mergedBoundariesForY(inspectY, sensors: input.sensors)

		return mergedBoundaries.map { $0.upperBound - $0.lowerBound }.reduce(0, +)
	}

	func solvePart2() -> Int {
		let maxCoordinate = 4_000_000

		for inspectY in 0 ... maxCoordinate {
			let mergedBoundaries = mergedBoundariesForY(inspectY, sensors: input.sensors)

			if mergedBoundaries.count > 1 {
				return ((mergedBoundaries.first!.upperBound + 1) * 4_000_000) + inspectY
			}
		}

		fatalError()
	}

	func parseInput(rawString: String) {
		input = .init(sensors: rawString.allLines().map { line in
			let values = line.getCapturedValues(pattern: #"Sensor at x=(-?[0-9]*), y=(-?[0-9]*): closest beacon is at x=(-?[0-9]*), y=(-?[0-9]*)"#)!

			return Sensor(position: .init(x: Int(values[0])!, y: Int(values[1])!), closestBeaconPosition: .init(x: Int(values[2])!, y: Int(values[3])!))
		})
	}
}
