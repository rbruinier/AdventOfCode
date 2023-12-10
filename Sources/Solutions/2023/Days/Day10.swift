import Collections
import Foundation
import Tools

final class Day10Solver: DaySolver {
	let dayNumber: Int = 10

	let expectedPart1Result = 6882
	let expectedPart2Result = 491

	private var input: Input!

	private struct Input {
		let startPosition: Point2D
		let pipes: [Point2D: Pipe]
	}

	private enum Pipe: Hashable {
		case vertical
		case horizontal
		case northEastBend
		case northWestBend
		case southWestBend
		case southEastBend
		case empty
	}

	private func pipe(at position: Point2D, pipes: [Point2D: Pipe]) -> Pipe {
		pipes[position, default: .empty]
	}

	private func neighbors(at position: Point2D, pipes: [Point2D: Pipe]) -> (n: Pipe, s: Pipe, w: Pipe, e: Pipe) {
		let n = pipe(at: position.moved(to: .north), pipes: pipes)
		let s = pipe(at: position.moved(to: .south), pipes: pipes)
		let w = pipe(at: position.moved(to: .west), pipes: pipes)
		let e = pipe(at: position.moved(to: .east), pipes: pipes)

		return (n: n, s: s, w: w, e: e)
	}

	private func startDirection(for pipe: Pipe) -> Direction {
		switch pipe {
		case .horizontal: .east
		case .vertical: .south
		case .southEastBend: .north
		case .southWestBend: .north
		case .northEastBend: .south
		case .northWestBend: .south
		default: preconditionFailure()
		}
	}

	private func resolveStartingPositionPipe(at position: Point2D, pipes: [Point2D: Pipe]) -> Pipe {
		let neighbors = neighbors(at: position, pipes: pipes)

		let westConnecting: Set<Pipe> = [.horizontal, .southEastBend, .northEastBend]
		let northConnecting: Set<Pipe> = [.vertical, .southEastBend, .southWestBend]
		let eastConnecting: Set<Pipe> = [.horizontal, .southWestBend, .northWestBend]
		let southConnecting: Set<Pipe> = [.vertical, .northEastBend, .northWestBend]

		let hasWestConnecting = westConnecting.contains(neighbors.w)
		let hasNorthConnecting = northConnecting.contains(neighbors.n)
		let hasEastConnecting = eastConnecting.contains(neighbors.e)
		let hasSouthConnecting = southConnecting.contains(neighbors.s)

		switch (hasWestConnecting, hasNorthConnecting, hasEastConnecting, hasSouthConnecting) {
		case (true, true, false, false): return .northWestBend
		case (true, false, true, false): return .horizontal
		case (true, false, false, true): return .southWestBend
		case (false, true, true, false): return .northEastBend
		case (false, true, false, true): return .vertical
		case (false, false, true, true): return .southEastBend
		case (true, false, false, false),
		     (true, true, true, false),
		     (true, true, true, true),
		     (true, false, true, true),
		     (true, true, false, true),
		     (false, true, false, false),
		     (false, true, true, true),
		     (false, false, true, false),
		     (false, false, false, true),
		     (false, false, false, false):
			preconditionFailure()
		}
	}

	private func movedToNextPipe(from point: inout Point2D, direction: inout Direction, pipes: [Point2D: Pipe]) {
		switch pipes[point, default: .empty] {
		case .empty: preconditionFailure()
		case .vertical: break
		case .horizontal: break
		case .southEastBend:
			switch direction {
			case .north: direction = .east
			case .west: direction = .south
			default: break
			}
		case .southWestBend:
			switch direction {
			case .north: direction = .west
			case .east: direction = .south
			default: break
			}
		case .northEastBend:
			switch direction {
			case .south: direction = .east
			case .west: direction = .north
			default: break
			}
		case .northWestBend:
			switch direction {
			case .south: direction = .west
			case .east: direction = .north
			default: break
			}
		}

		point = point.moved(to: direction)
	}

	private func traverseCompleteLoop(from point: Point2D, startDirection: Direction, pipes: [Point2D: Pipe]) -> [Point2D: Int] {
		var direction = startDirection
		var currentPoint = point

		var visitedPoints: [Point2D: Int] = [currentPoint: 0]

		var distance = 1
		while true {
			defer {
				distance += 1
			}

			movedToNextPipe(from: &currentPoint, direction: &direction, pipes: pipes)

			if visitedPoints.keys.contains(currentPoint) {
				break
			}

			visitedPoints[currentPoint] = distance
		}

		return visitedPoints
	}

	func solvePart1() -> Int {
		var pipes = input.pipes

		pipes[input.startPosition] = resolveStartingPositionPipe(at: input.startPosition, pipes: pipes)

		let visitedPoints = traverseCompleteLoop(
			from: input.startPosition,
			startDirection: startDirection(for: pipes[input.startPosition]!),
			pipes: pipes
		)

		return visitedPoints.values.sorted()[visitedPoints.count / 2]
	}

	func solvePart2() -> Int {
		var pipes = input.pipes

		pipes[input.startPosition] = resolveStartingPositionPipe(at: input.startPosition, pipes: pipes)

		let pipePoints = traverseCompleteLoop(
			from: input.startPosition,
			startDirection: startDirection(for: pipes[input.startPosition]!),
			pipes: pipes
		)

		let mainPipePositions = Set(pipePoints.keys)

		let maxX = 139
		let maxY = 139

		// by row walk from left to right. Any time a vertical oriented pipe is passed we increase a counter
		// when we are on a non main pipeline piece we can count the piece as in if we are on an uneven piece counter
		var counter = 0
		for y in 1 ..< maxY {
			var encounterCounter = 0

			for x in 0 ... maxX {
				let point = Point2D(x: x, y: y)

				if mainPipePositions.contains(point) {
					if Set([Pipe.vertical, Pipe.northWestBend, Pipe.northEastBend]).contains(pipes[point]) {
						encounterCounter += 1
					}
				} else {
					counter += (encounterCounter % 2 == 1) ? 1 : 0
				}
			}
		}

		return counter
	}

	func parseInput(rawString: String) {
		var startPosition: Point2D!
		var pipes: [Point2D: Pipe] = [:]

		rawString.allLines().enumerated().forEach { y, line in
			line.enumerated().forEach { x, character in
				let position = Point2D(x: x, y: y)

				switch character {
				case ".": pipes[position] = .empty
				case "S": startPosition = position
				case "-": pipes[position] = .horizontal
				case "|": pipes[position] = .vertical
				case "L": pipes[position] = .northEastBend
				case "J": pipes[position] = .northWestBend
				case "7": pipes[position] = .southWestBend
				case "F": pipes[position] = .southEastBend
				default: preconditionFailure()
				}
			}
		}
		input = .init(
			startPosition: startPosition,
			pipes: pipes
		)
	}
}
