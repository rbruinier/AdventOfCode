import Collections
import Foundation
import Tools

final class Day20Solver: DaySolver {
	let dayNumber: Int = 20

	// cached part 1 result for part 2
	private var shortestDistances: [Point2D: Int]!

	struct Input {
		let regex: AsciiString
	}

	private enum Instruction: Hashable {
		case move(direction: Direction)
		case branch(instructions: [[Instruction]])
	}

	private func parseInstructions(_ instructions: AsciiString) -> [[Instruction]] {
		var position = 0
		var parenthesisCount = 0
		var parenthesisStartIndex: Int?

		var branchIndex = 0
		var branches: [[Instruction]] = [[]]

		while position < instructions.count {
			switch instructions[position] {
			case AsciiCharacter("("):
				parenthesisCount += 1

				if parenthesisCount == 1 {
					parenthesisStartIndex = position
				}
			case AsciiCharacter(")"):
				parenthesisCount -= 1

				if parenthesisCount == 0 {
					branches[branchIndex] += [.branch(instructions: parseInstructions(AsciiString(instructions[parenthesisStartIndex! + 1 ..< position])))]

					parenthesisStartIndex = nil
				}
			case AsciiCharacter("|"):
				if parenthesisCount == 0 {
					branchIndex += 1

					branches.append([])
				}
			case AsciiCharacter("W"):
				branches[branchIndex] += parenthesisCount == 0 ? [.move(direction: .west)] : []
			case AsciiCharacter("E"):
				branches[branchIndex] += parenthesisCount == 0 ? [.move(direction: .east)] : []
			case AsciiCharacter("N"):
				branches[branchIndex] += parenthesisCount == 0 ? [.move(direction: .north)] : []
			case AsciiCharacter("S"):
				branches[branchIndex] += parenthesisCount == 0 ? [.move(direction: .south)] : []
			default:
				preconditionFailure()
			}

			position += 1
		}

		return branches
	}

	private class Map {
		var doors: Set<Point2D> = []
	}

	private struct CacheKey: Hashable {
		let startPoint: Point2D
		let instructions: [Instruction]
	}

	private var cache: Set<Int> = []

	private func fillMap(_ map: Map, startingAt startPoint: Point2D, instructions: [Instruction]) {
		let cacheKey = CacheKey(startPoint: startPoint, instructions: instructions).hashValue

		if cache.contains(cacheKey) {
			return
		}

		cache.insert(cacheKey)

		var position = startPoint

		for (index, instruction) in instructions.enumerated() {
			switch instruction {
			case .move(let direction):
				let doorPosition = position.moved(to: direction, steps: 1)
				position = position.moved(to: direction, steps: 2)

				map.doors.insert(doorPosition)

			case .branch(let branches):
				let remainingInstructions = instructions[index + 1 ..< instructions.count]

				for branchInstructions in branches {
					fillMap(map, startingAt: position, instructions: branchInstructions + remainingInstructions)
				}

				return
			}
		}
	}

	private func findShortestDistanceForEachRoom(in map: Map) -> [Point2D: Int] {
		var visitedRooms: Set<Point2D> = []

		struct Node {
			let point: Point2D
			let steps: Int
		}

		var queue: Deque<Node> = [.init(point: .zero, steps: 0)]
		var distances: [Point2D: Int] = [:]

		while let node = queue.popFirst() {
			visitedRooms.insert(node.point)
			distances[node.point] = node.steps

			for neighbor in node.point.neighbors() {
				let neighborRoomPoint = neighbor + (neighbor - node.point)

				guard
					!visitedRooms.contains(neighborRoomPoint),
					map.doors.contains(neighbor)
				else {
					continue
				}

				queue.append(.init(point: neighborRoomPoint, steps: node.steps + 1))
			}
		}

		return distances
	}

	func solvePart1(withInput input: Input) -> Int {
		let instructions = parseInstructions(input.regex)

		guard instructions.count == 1 else {
			preconditionFailure("Expect only one root set of instructions")
		}

		let map = Map()

		fillMap(map, startingAt: .zero, instructions: instructions[0])

		shortestDistances = findShortestDistanceForEachRoom(in: map)

		return shortestDistances.values.max()!
	}

	func solvePart2(withInput input: Input) -> Int {
		shortestDistances.filter { $0.value >= 1000 }.count
	}

	func parseInput(rawString: String) -> Input {
		let firstLine = rawString.allLines().first!

		return .init(regex: AsciiString(string: firstLine[1 ..< firstLine.count - 1]))
	}
}
