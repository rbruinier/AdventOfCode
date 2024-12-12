import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	private var input: Input!

	private struct Input {
		let size: Size
		let antennas: [Character: [Point2D]]
	}

	private static func solve(antennas: [Character: [Point2D]], size: Size, performLoop: Bool) -> Int {
		var antinodes: Set<Point2D> = []

		for (_, positions) in antennas {
			for aIndex in 0 ..< positions.count {
				let aPosition = positions[aIndex]

				if performLoop {
					antinodes.insert(aPosition)
				}

				for bIndex in aIndex + 1 ..< positions.count {
					let bPosition = positions[bIndex]

					let delta = bPosition - aPosition

					var currentPosition = aPosition

					while true {
						currentPosition -= delta

						guard (0 ..< size.width).contains(currentPosition.x), (0 ..< size.height).contains(currentPosition.y) else {
							break
						}

						antinodes.insert(currentPosition)

						guard performLoop else {
							break
						}
					}

					currentPosition = bPosition

					while true {
						currentPosition += delta

						guard (0 ..< size.width).contains(currentPosition.x), (0 ..< size.height).contains(currentPosition.y) else {
							break
						}

						antinodes.insert(currentPosition)

						guard performLoop else {
							break
						}
					}
				}
			}
		}

		return antinodes.count
	}

	func solvePart1() -> Int {
		Self.solve(antennas: input.antennas, size: input.size, performLoop: false)
	}

	func solvePart2() -> Int {
		Self.solve(antennas: input.antennas, size: input.size, performLoop: true)
	}

	func parseInput(rawString: String) {
		var antennas: [Character: [Point2D]] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, id) in line.enumerated() where id != "." {
				antennas[id, default: []].append(.init(x: x, y: y))
			}
		}

		input = .init(
			size: .init(width: 50, height: 50),
			antennas: antennas
		)
	}
}
