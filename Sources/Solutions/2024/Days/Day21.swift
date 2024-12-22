import Collections
import Foundation
import Tools

final class Day21Solver: DaySolver {
	let dayNumber: Int = 21

	struct Input {
		let inputs: [[Key]]
	}

	enum Key: String, Hashable, CaseIterable {
		case zero = "0"
		case one = "1"
		case two = "2"
		case three = "3"
		case four = "4"
		case five = "5"
		case six = "6"
		case seven = "7"
		case eight = "8"
		case nine = "9"
		case left = "<"
		case right = ">"
		case up = "^"
		case down = "v"
		case enter = "A"
	}

	private struct KeyFromToCacheKey: Hashable {
		let a: Key
		let b: Key
	}

	private typealias Path = [Key]

	private var keyPathsCache: [KeyFromToCacheKey: [Path]] = [:]
	private var solveMemoization: [Int: Int] = [:]

	private func setupPathsCache() {
		let numericPadCoordinates: [Key: Point2D] = [
			.seven: Point2D(x: 0, y: 0),
			.eight: Point2D(x: 1, y: 0),
			.nine: Point2D(x: 2, y: 0),
			.four: Point2D(x: 0, y: 1),
			.five: Point2D(x: 1, y: 1),
			.six: Point2D(x: 2, y: 1),
			.one: Point2D(x: 0, y: 2),
			.two: Point2D(x: 1, y: 2),
			.three: Point2D(x: 2, y: 2),
			.zero: Point2D(x: 1, y: 3),
			.enter: Point2D(x: 2, y: 3),
		]

		let directionPadCoordinates: [Key: Point2D] = [
			.up: Point2D(x: 1, y: 0),
			.enter: Point2D(x: 2, y: 0),
			.left: Point2D(x: 0, y: 1),
			.down: Point2D(x: 1, y: 1),
			.right: Point2D(x: 2, y: 1),
		]

		let numericKeys: [Key] = [.zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .enter]
		let directionKeys: [Key] = [.left, .up, .right, .down, .enter]

		for a in numericKeys {
			for b in numericKeys {
				let paths = Self.pathsOnKeyPath(from: a, to: b, coordinates: numericPadCoordinates)

				keyPathsCache[.init(a: a, b: b)] = paths
			}
		}

		for a in directionKeys {
			for b in directionKeys {
				let paths = Self.pathsOnKeyPath(from: a, to: b, coordinates: directionPadCoordinates)

				keyPathsCache[.init(a: a, b: b)] = paths
			}
		}
	}

	private static func pathsOnKeyPath(from: Key, to: Key, coordinates: [Key: Point2D]) -> [[Key]] {
		let validCoordinates: Set<Point2D> = Set(coordinates.values)

		var paths: [Path] = []

		struct Node {
			let startPosition: Point2D
			let position: Point2D
			let visitedPositions: Set<Point2D>
			let path: Path
		}

		let startPosition = coordinates[from]!
		let endPosition = coordinates[to]!

		let manhattanDistance = endPosition.manhattanDistance(from: startPosition)

		var nodes: Deque<Node> = [.init(startPosition: startPosition, position: startPosition, visitedPositions: [startPosition], path: [])]

		while let node = nodes.popFirst() {
			if node.position == endPosition {
				paths.append(node.path)

				continue
			}

			if node.visitedPositions.count > manhattanDistance {
				continue
			}

			for neighbor in node.position.neighbors() where validCoordinates.contains(neighbor) {
				guard !node.visitedPositions.contains(neighbor) else {
					continue
				}

				let action: Key

				switch neighbor - node.position {
				case Point2D(x: -1, y: 0): action = .left
				case Point2D(x: 1, y: 0): action = .right
				case Point2D(x: 0, y: -1): action = .up
				case Point2D(x: 0, y: 1): action = .down
				default: preconditionFailure()
				}

				nodes.append(Node(
					startPosition: node.startPosition,
					position: neighbor,
					visitedPositions: node.visitedPositions.union([neighbor]),
					path: node.path + [action]
				))
			}
		}

		return paths
	}

	/// This function constructs all possible sequences for the parent layer of the provided keys
	private func extractSequences(from path: Path, index: Int, previousKey: Key, parentPath: [Key], result: inout [[Key]]) {
		guard index < path.count else {
			result.append(parentPath)

			return
		}

		for newPath in keyPathsCache[.init(a: previousKey, b: path[index])]! {
			extractSequences(from: path, index: index + 1, previousKey: path[index], parentPath: parentPath + newPath + [.enter], result: &result)
		}
	}

	/// Recursively solves multiple layers of direction robots by dealing with sub sequences by dividing the keys by the enter key as that is always the last position anyway.
	private func solveDirectionRobots(path: Path, depth: Int) -> Int {
		struct MemoizationKey: Hashable {
			let path: Path
			let depth: Int
		}

		guard depth >= 1 else {
			return path.count
		}

		let cacheHash = MemoizationKey(path: path, depth: depth).hashValue

		if let cachedResult = solveMemoization[cacheHash] {
			return cachedResult
		}

		var subdividedPaths: [Path] = [[]]

		for key in path {
			subdividedPaths[subdividedPaths.count - 1].append(key)

			if key == .enter {
				subdividedPaths.append([])
			}
		}

		var total = 0

		for subPath in subdividedPaths where subPath.isNotEmpty {
			var result: [Path] = []

			extractSequences(from: subPath, index: 0, previousKey: .enter, parentPath: [], result: &result)

			var shortestSequenceLength = Int.max

			for sequence in result {
				shortestSequenceLength = min(shortestSequenceLength, solveDirectionRobots(path: sequence, depth: depth - 1))
			}

			total += shortestSequenceLength
		}

		solveMemoization[cacheHash] = total

		return total
	}

	private func solveWithInputs(inputs: [[Key]], numberOfDirectionRobots: Int) -> Int {
		var result = 0

		for inputKeys in inputs {
			let numericPart = Int(inputKeys.map(\.rawValue).joined()[0 ..< 3])!

			var rootPaths: [[Key]] = []

			extractSequences(from: inputKeys, index: 0, previousKey: .enter, parentPath: [], result: &rootPaths)

			var shortestSequenceLength = Int.max

			for path in rootPaths {
				shortestSequenceLength = min(shortestSequenceLength, solveDirectionRobots(path: path, depth: numberOfDirectionRobots))
			}

			result += numericPart * shortestSequenceLength
		}

		return result
	}

	func solvePart1(withInput input: Input) -> Int {
		setupPathsCache()

		return solveWithInputs(inputs: input.inputs, numberOfDirectionRobots: 2)
	}

	func solvePart2(withInput input: Input) -> Int {
		solveWithInputs(inputs: input.inputs, numberOfDirectionRobots: 25)
	}

	func parseInput(rawString: String) -> Input {
		.init(inputs: rawString.allLines().map { $0.map { Key(rawValue: String($0))! }})
	}
}
