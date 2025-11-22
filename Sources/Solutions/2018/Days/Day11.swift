import Foundation
import Tools

/// Caches sums for point + size so we can calculate larger sizes by using cached square value of 1 size smaller and only calculate power level of the new borders
final class Day11Solver: DaySolver {
	let dayNumber: Int = 11

	struct Input {
		let serialNumber: Int
	}

	private struct CacheKey: Hashable {
		let position: Point2D
		let size: Int
	}

	private var cache: [CacheKey: Int] = [:]

	private func powerLevel(at point: Point2D, serial: Int) -> Int {
		// Find the fuel cell's rack ID, which is its X coordinate plus 10.
		let rackID = point.x + 10

		// Begin with a power level of the rack ID times the Y coordinate.
		var powerLevel = rackID * point.y

		// Increase the power level by the value of the grid serial number (your puzzle input).
		powerLevel += serial

		// Set the power level to itself multiplied by the rack ID.
		powerLevel = powerLevel * rackID

		// Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
		powerLevel = (powerLevel / 100) % 10

		// Subtract 5 from the power level.
		powerLevel -= 5

		return powerLevel
	}

	private func powerLevelOfSquare(at point: Point2D, size: Int, serial: Int) -> Int {
		var sum = 0

		if let cachedSum = cache[.init(position: point, size: size - 1)] {
			sum = cachedSum

			let maxX = point.x + size - 1
			let maxY = point.y + size - 1

			for y in point.y ..< point.y + size {
				sum += powerLevel(at: .init(x: maxX, y: y), serial: serial)
			}

			for x in point.x ..< point.x + size {
				sum += powerLevel(at: .init(x: x, y: maxY), serial: serial)
			}
		} else {
			for y in point.y ..< point.y + size {
				for x in point.x ..< point.x + size {
					sum += powerLevel(at: .init(x: x, y: y), serial: serial)
				}
			}
		}

		cache[.init(position: point, size: size)] = sum

		return sum
	}

	private func bestLevelOfSquare(withSize size: Int, serial: Int) -> (point: Point2D, sum: Int) {
		var bestSum = 0
		var bestPoint: Point2D = .zero

		for y in 1 ..< 300 - size {
			for x in 1 ..< 300 - size {
				let sum = powerLevelOfSquare(at: .init(x: x, y: y), size: size, serial: serial)

				if sum > bestSum {
					bestSum = sum
					bestPoint = .init(x: x, y: y)
				}
			}
		}

		return (point: bestPoint, sum: bestSum)
	}

	func solvePart1(withInput input: Input) -> String {
		let (bestPoint, _) = bestLevelOfSquare(withSize: 3, serial: input.serialNumber)

		return "\(bestPoint.x),\(bestPoint.y)"
	}

	func solvePart2(withInput input: Input) -> String {
		var bestSum = 0
		var bestPoint = Point2D.zero
		var bestSize = 0

		for size in 1 ..< 300 {
			let (point, sum) = bestLevelOfSquare(withSize: size, serial: input.serialNumber)

			if sum > bestSum {
				bestSum = sum
				bestPoint = point
				bestSize = size
			}
		}

		return "\(bestPoint.x),\(bestPoint.y),\(bestSize)"
	}

	func parseInput(rawString: String) -> Input {
		.init(serialNumber: 9424)
	}
}
