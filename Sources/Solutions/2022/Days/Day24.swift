import Collections
import Foundation
import Tools

/// Pre calculate all possible blizzard configurations (width x height). After this everything starts repeating. We also precalculate the hash value for this
/// because calculating hashes for sets appears to be slow.
///
/// After that keep track of visited hashes of position + blizzard state so we don't explore same setup multiple times.
final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	private var input: Input!

	private struct Input {
		let blizzards: [Point2D: [Direction]]

		let areaSize: Size

		let startPoint: Point2D
		let endPoint: Point2D
	}

	private enum Tile {
		case floor
		case wall
	}

	init() {}

	private func moveBlizzards(_ blizzards: [Point2D: [Direction]], areaSize: Size) -> [Point2D: [Direction]] {
		var newBlizzards: [Point2D: [Direction]] = [:]

		for (point, directions) in blizzards {
			for direction in directions {
				var nextPoint = point.moved(to: direction)

				if nextPoint.x == areaSize.width {
					nextPoint.x = 0
				} else if nextPoint.x == -1 {
					nextPoint.x = areaSize.width - 1
				}

				if nextPoint.y == areaSize.height {
					nextPoint.y = 0
				} else if nextPoint.y == -1 {
					nextPoint.y = areaSize.height - 1
				}

				newBlizzards[nextPoint] = newBlizzards[nextPoint, default: []] + [direction]
			}
		}

		return newBlizzards
	}

	private func generateCachedBlizzards() -> [Int: (points: Set<Point2D>, hash: Int)] {
		var blizzards = input.blizzards
		var cachedBlizzards: [Int: (points: Set<Point2D>, hash: Int)] = [:]

		for step in 0 ..< input.areaSize.width * input.areaSize.height {
			let asSet = Set(blizzards.keys)

			cachedBlizzards[step] = (points: asSet, hash: asSet.hashValue)

			blizzards = moveBlizzards(blizzards, areaSize: input.areaSize)
		}

		return cachedBlizzards
	}

	private func shortestPath(from: Point2D, to: Point2D, startSteps: Int, cachedBlizzards: [Int: (points: Set<Point2D>, hash: Int)]) -> Int {
		struct State {
			let position: Point2D
			let steps: Int
		}

		func hashFor(position: Point2D, blizzards: Int) -> Int {
			var hasher = Hasher()

			hasher.combine(position)
			hasher.combine(blizzards)

			return hasher.finalize()
		}

		var queue: Deque<State> = [
			.init(position: from, steps: startSteps),
		]

		let cacheSize = input.areaSize.width * input.areaSize.height

		var visitedHashes: Set<Int> = [hashFor(position: from, blizzards: cachedBlizzards[startSteps % cacheSize]!.hash)]

		while let state = queue.popFirst() {
			let nextStep = state.steps + 1

			let blizzards = cachedBlizzards[nextStep % cacheSize]!

			for nextPoint in state.position.neighbors() {
				if nextPoint == to {
					return nextStep
				}

				guard
					(0 ..< input.areaSize.width).contains(nextPoint.x),
					(0 ..< input.areaSize.height).contains(nextPoint.y),
					blizzards.points.contains(nextPoint) == false
				else {
					continue
				}

				let hash = hashFor(position: nextPoint, blizzards: blizzards.hash)

				guard visitedHashes.contains(hash) == false else {
					continue
				}

				visitedHashes.insert(hash)

				queue.append(
					.init(
						position: nextPoint,
						steps: nextStep
					)
				)
			}

			if blizzards.points.contains(state.position) == false {
				queue.append(
					.init(
						position: state.position,
						steps: nextStep
					)
				)
			}
		}

		fatalError()
	}

	func solvePart1() -> Int {
		let cachedBlizzards = generateCachedBlizzards()

		return shortestPath(from: input.startPoint, to: input.endPoint, startSteps: 0, cachedBlizzards: cachedBlizzards)
	}

	func solvePart2() -> Int {
		let cachedBlizzards = generateCachedBlizzards()

		var steps = shortestPath(from: input.startPoint, to: input.endPoint, startSteps: 0, cachedBlizzards: cachedBlizzards)

		steps = shortestPath(from: input.endPoint, to: input.startPoint, startSteps: steps, cachedBlizzards: cachedBlizzards)
		steps = shortestPath(from: input.startPoint, to: input.endPoint, startSteps: steps, cachedBlizzards: cachedBlizzards)

		return steps
	}

	func parseInput(rawString: String) {
		let allLines = rawString.allLines()

		var blizzards: [Point2D: [Direction]] = [:]

		let width = allLines.first!.count - 2
		let height = allLines.count - 2

		for (y, line) in rawString.allLines().enumerated() {
			for (x, char) in line.enumerated() {
				let point = Point2D(x: x - 1, y: y - 1)

				switch char {
				case "<":
					blizzards[point] = [.west]
				case ">":
					blizzards[point] = [.east]
				case "^":
					blizzards[point] = [.north]
				case "v":
					blizzards[point] = [.south]
				case "#",
				     ".":
					break
				default:
					fatalError()
				}
			}
		}

		input = .init(
			blizzards: blizzards,
			areaSize: .init(
				width: width,
				height: height
			),
			startPoint: .init(x: 0, y: -1),
			endPoint: .init(x: width - 1, y: height)
		)
	}
}
