import Collections
import Foundation
import Tools

/// Part 1 is straight forward implementation. Second part is solved by collecting all right handed coordinates for the path (could also have been left handed but this worked). Either
/// all the right or left handed coordinates are inside the loop (unless they are part of the path, of course). After that a rudimentary flood fiill is done for each of the inside coordinates.
final class Day10Solver: DaySolver {
	let dayNumber: Int = 10

	struct Input {
		let startPosition: Point2D
		let pipes: [Point2D: Pipe]
	}

	enum Pipe: Hashable {
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
		default: preconditionFailure()
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

	private func collectRightHandedPoints(for point: Point2D, direction: Direction, pipes: [Point2D: Pipe]) -> Set<Point2D> {
		var rightHandedPoints: Set<Point2D> = []

		rightHandedPoints.insert(point.moved(to: direction.right))

		switch pipes[point]! {
		case .northEastBend:
			switch direction {
			case .south:
				rightHandedPoints.insert(point.moved(to: direction.right).moved(to: .south))
				rightHandedPoints.insert(point.moved(to: .south))
			default: break
			}
		case .northWestBend:
			switch direction {
			case .east:
				rightHandedPoints.insert(point.moved(to: direction.right).moved(to: .east))
				rightHandedPoints.insert(point.moved(to: .east))
			default: break
			}
		case .southEastBend:
			switch direction {
			case .south:
				rightHandedPoints.insert(point.moved(to: direction.right).moved(to: .south))
				rightHandedPoints.insert(point.moved(to: .south))
			default: break
			}
		case .southWestBend:
			switch direction {
			case .south:
				rightHandedPoints.insert(point.moved(to: direction.right).moved(to: .west))
				rightHandedPoints.insert(point.moved(to: .west))
			default: break
			}
		default: break
		}

		return rightHandedPoints
	}

	private func traverseCompleteLoop(from point: Point2D, startDirection: Direction, pipes: [Point2D: Pipe]) -> (points: [Point2D: Int], rightHandedPoints: Set<Point2D>) {
		var direction = startDirection
		var currentPoint = point

		var visitedPoints: [Point2D: Int] = [currentPoint: 0]
		var rightHandedPoints: Set<Point2D> = []

		var distance = 1
		while true {
			defer {
				distance += 1
			}

			movedToNextPipe(from: &currentPoint, direction: &direction, pipes: pipes)

			rightHandedPoints = rightHandedPoints.union(collectRightHandedPoints(for: currentPoint, direction: direction, pipes: pipes))

			if visitedPoints.keys.contains(currentPoint) {
				break
			}

			visitedPoints[currentPoint] = distance
		}

		return (points: visitedPoints, rightHandedPoints: rightHandedPoints)
	}

	func solvePart1(withInput input: Input) -> Int {
		var pipes = input.pipes

		pipes[input.startPosition] = resolveStartingPositionPipe(at: input.startPosition, pipes: pipes)

		let result = traverseCompleteLoop(
			from: input.startPosition,
			startDirection: startDirection(for: pipes[input.startPosition]!),
			pipes: pipes
		)

		return result.points.values.sorted()[result.points.count / 2]
	}

	func solvePart2(withInput input: Input) -> Int {
		var pipes = input.pipes

		pipes[input.startPosition] = resolveStartingPositionPipe(at: input.startPosition, pipes: pipes)

		let traverseResult = traverseCompleteLoop(
			from: input.startPosition,
			startDirection: startDirection(for: pipes[input.startPosition]!),
			pipes: pipes
		)

		let mainPipePositions = Set(traverseResult.points.keys)

		let xRange = 0 ..< pipes.map(\.key.x).max()!
		let yRange = 0 ..< pipes.map(\.key.y).max()!

		var pointsQueue: Deque<Point2D> = .init(traverseResult.rightHandedPoints.filter { !mainPipePositions.contains($0) })
		var allInsidePoints: Set<Point2D> = []

		while let point = pointsQueue.popFirst() {
			allInsidePoints.insert(point)

			for neighbor in point.neighbors() where !allInsidePoints.contains(neighbor) && !mainPipePositions.contains(neighbor) {
				guard xRange.contains(neighbor.x), yRange.contains(neighbor.y) else {
					fatalError()
				}

				pointsQueue.append(neighbor)
			}
		}

		return allInsidePoints.count
	}

	func parseInput(rawString: String) -> Input {
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
		return .init(
			startPosition: startPosition,
			pipes: pipes
		)
	}
}
