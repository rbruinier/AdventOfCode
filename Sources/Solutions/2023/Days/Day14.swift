import Foundation
import Tools

final class Day14Solver: DaySolver {
	let dayNumber: Int = 14

	private var input: Input!

	private struct Input {
		let roundRocks: Set<Point2D>
		let cubeRocks: Set<Point2D>

		let size: Size
	}

	private func move(roundRocks: Set<Point2D>, cubeRocks: Set<Point2D>, direction: Direction, size: Size) -> Set<Point2D> {
		var newRocks: Set<Point2D> = .init(minimumCapacity: roundRocks.count)

		switch direction {
		case .north:
			let sortedRocks: [Point2D] = roundRocks.sorted { $0.y < $1.y }

			for originalRockPosition in sortedRocks {
				var newRockPosition = originalRockPosition

				while true {
					let newestRockPosition = newRockPosition.moved(to: .north)

					if newestRockPosition.y < 0 || newRocks.contains(newestRockPosition) || cubeRocks.contains(newestRockPosition) {
						newRocks.insert(newRockPosition)

						break
					}

					newRockPosition = newestRockPosition
				}
			}
		case .south:
			let sortedRocks: [Point2D] = roundRocks.sorted { $0.y > $1.y }

			for originalRockPosition in sortedRocks {
				var newRockPosition = originalRockPosition

				while true {
					let newestRockPosition = newRockPosition.moved(to: .south)

					if newestRockPosition.y >= size.height || newRocks.contains(newestRockPosition) || cubeRocks.contains(newestRockPosition) {
						newRocks.insert(newRockPosition)

						break
					}

					newRockPosition = newestRockPosition
				}
			}
		case .west:
			let sortedRocks: [Point2D] = roundRocks.sorted { $0.x < $1.x }

			for originalRockPosition in sortedRocks {
				var newRockPosition = originalRockPosition

				while true {
					let newestRockPosition = newRockPosition.moved(to: .west)

					if newestRockPosition.x < 0 || newRocks.contains(newestRockPosition) || cubeRocks.contains(newestRockPosition) {
						newRocks.insert(newRockPosition)

						break
					}

					newRockPosition = newestRockPosition
				}
			}
		case .east:
			let sortedRocks: [Point2D] = roundRocks.sorted { $0.x > $1.x }

			for originalRockPosition in sortedRocks {
				var newRockPosition = originalRockPosition

				while true {
					let newestRockPosition = newRockPosition.moved(to: .east)

					if newestRockPosition.x >= size.width || newRocks.contains(newestRockPosition) || cubeRocks.contains(newestRockPosition) {
						newRocks.insert(newRockPosition)

						break
					}

					newRockPosition = newestRockPosition
				}
			}
		default: preconditionFailure()
		}

		return newRocks
	}

	private func calculateWeight(for rocks: Set<Point2D>, size: Size) -> Int {
		rocks.reduce(into: 0) { result, position in
			result += size.height - position.y
		}
	}

	func solvePart1() -> Int {
		let roundRocks = move(roundRocks: input.roundRocks, cubeRocks: input.cubeRocks, direction: .north, size: input.size)

		return calculateWeight(for: roundRocks, size: input.size)
	}

	func solvePart2() -> Int {
		var roundRocks = input.roundRocks

		// we hash the rock configuration and store the cycle number for each hash
		var existingCycleHashes: [Int: Int] = [:]

		// for each cycle we also store the rock configuration so once we have found the loop in the cycles
		// we can just look the final configuration up in the cache
		var roundRocksByCycle: [Int: Set<Point2D>] = [:]

		let numberOfCycles = 1_000_000_000
		let directions: [Direction] = [.north, .west, .south, .east]

		for cycle in 0 ..< numberOfCycles {
			for direction in directions {
				roundRocks = move(roundRocks: roundRocks, cubeRocks: input.cubeRocks, direction: direction, size: input.size)
			}

			let hash = roundRocks.hashValue

			if let identicalCycle = existingCycleHashes[hash] {
				let finalCycle = Math.solveCycle(withStartIndex: identicalCycle, endIndex: cycle, numberOfCycles: numberOfCycles)

				roundRocks = roundRocksByCycle[finalCycle]!

				break
			} else {
				existingCycleHashes[hash] = cycle
				roundRocksByCycle[cycle] = roundRocks
			}
		}

		return calculateWeight(for: roundRocks, size: input.size)
	}

	func parseInput(rawString: String) {
		var roundRocks: Set<Point2D> = []
		var cubeRocks: Set<Point2D> = []

		var maxSize: Size = .zero

		for (y, line) in rawString.allLines().enumerated() {
			for (x, character) in line.enumerated() {
				let point = Point2D(x: x, y: y)

				switch character {
				case ".": break
				case "#": cubeRocks.insert(point)
				case "O": roundRocks.insert(point)
				default: preconditionFailure()
				}
			}

			maxSize = .init(width: max(maxSize.width, line.count), height: max(maxSize.height, y + 1))
		}

		input = .init(roundRocks: roundRocks, cubeRocks: cubeRocks, size: maxSize)
	}
}
