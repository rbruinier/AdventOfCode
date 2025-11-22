import Foundation
import Tools

final class Day03Solver: DaySolver {
	let dayNumber: Int = 3

	struct Input {
		let squareID: Int
	}

	/// Source of this function: https://math.stackexchange.com/a/163101
	private func spiralPoint(for n: Int) -> Point2D {
		let k = Int(ceil((sqrt(Float(n)) - 1) / 2))

		var t = 2 * k + 1
		var m = t * t

		t = t - 1

		if n >= m - t {
			return .init(x: k - (m - n), y: -k)
		}

		m = m - t

		if n >= m - t {
			return .init(x: -k, y: -k + (m - n))
		}

		m = m - t

		if n >= m - t {
			return .init(x: -k + (m - n), y: k)
		} else {
			return .init(x: k, y: k - (m - n - t))
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		let point = spiralPoint(for: input.squareID)

		return abs(point.x) + abs(point.y)
	}

	func solvePart2(withInput input: Input) -> Int {
		var sumsPerPoint: [Point2D: Int] = [:]

		for n in 1 ... 100 {
			let point = spiralPoint(for: n)

			let neighbors = point.neighbors(includingDiagonals: true)

			var sum = 0

			for neighborPoint in neighbors {
				sum += sumsPerPoint[neighborPoint, default: 0]
			}

			if sum > input.squareID {
				return sum
			}

			sumsPerPoint[point] = max(1, sum)
		}

		return 0
	}

	func parseInput(rawString: String) -> Input {
		.init(squareID: 277_678)
	}
}
