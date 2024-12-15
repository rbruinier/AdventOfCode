import Collections
import Foundation
import Tools

final class Day15Solver: DaySolver {
	let dayNumber: Int = 15

	struct Input {
		let boxes: Set<Point2D>
		let startPosition: Point2D
		let walls: Set<Point2D>
		let instructions: [Direction]
	}

	private struct Box {
		let id: Int
		var position: Point2D
		let width: Int

		var horizontalRange: ClosedRange<Int> {
			position.x ... position.x + (width - 1)
		}

		func overlaps(point: Point2D) -> Bool {
			position.y == point.y && horizontalRange.contains(point.x)
		}
	}

	private func printState(position: Point2D, boxes: [Int: Box], walls: Set<Point2D>) {
		let maxX = walls.map(\.x).max()!
		let maxY = walls.map(\.y).max()!

		for y in 0 ... maxY {
			var line = ""

			for x in 0 ... maxX {
				let point = Point2D(x: x, y: y)

				if point == position {
					line += "@"
				} else if walls.contains(point) {
					line += "#"
				} else if let box = boxAt(point, boxes: boxes), box.position == point {
					line += "[]"
				} else {
					if boxAt(point, boxes: boxes) == nil {
						line += "."
					}
				}
			}

			print(line)
		}
	}

	private func boxAt(_ point: Point2D, boxes: [Int: Box]) -> Box? {
		boxes.values.first(where: { $0.overlaps(point: point) })
	}

	private func widenMap(boxes: Set<Point2D>, walls: Set<Point2D>, startPoint: Point2D) -> (boxes: [Int: Box], walls: Set<Point2D>, startPoint: Point2D) {
		var newBoxes: [Int: Box] = [:]
		var newWalls: Set<Point2D> = []

		for (id, box) in boxes.enumerated() {
			newBoxes[id] = .init(id: id, position: Point2D(x: box.x * 2, y: box.y), width: 2)
		}

		for wall in walls {
			newWalls.insert(.init(x: wall.x * 2, y: wall.y))
			newWalls.insert(.init(x: wall.x * 2 + 1, y: wall.y))
		}

		return (boxes: newBoxes, walls: newWalls, startPoint: Point2D(x: startPoint.x * 2, y: startPoint.y))
	}

	private func score(boxes: Set<Point2D>) -> Int {
		boxes.map { $0.y * 100 + $0.x }.reduce(0, +)
	}

	private func verticallyMovableBoxIds(at point: Point2D, direction: Direction, boxes: [Int: Box], walls: Set<Point2D>) -> Set<Int> {
		guard let box = boxAt(point, boxes: boxes) else {
			return []
		}

		var boxIdsToCheck: Deque<Int> = [box.id]
		var movedBoxesIds: Set<Int> = []

		while let boxIdToCheck = boxIdsToCheck.popFirst() {
			let boxToCheck = boxes[boxIdToCheck]!

			movedBoxesIds.insert(boxToCheck.id)

			for x in boxToCheck.horizontalRange {
				let boxPoint = Point2D(x: x, y: boxToCheck.position.moved(to: direction).y)

				if walls.contains(boxPoint) {
					return []
				}

				if let nextBox = boxAt(boxPoint, boxes: boxes), !movedBoxesIds.contains(nextBox.id) {
					boxIdsToCheck.append(nextBox.id)
				}
			}
		}

		return movedBoxesIds
	}

	private func horizontallyMovableBoxIds(at point: Point2D, direction: Direction, boxes: [Int: Box], walls: Set<Point2D>) -> Set<Int> {
		guard let box = boxAt(point, boxes: boxes) else {
			return []
		}

		var boxIdsToCheck: Deque<Int> = [box.id]
		var movedBoxesIds: Set<Int> = []

		while let boxIdToCheck = boxIdsToCheck.popFirst() {
			let boxToCheck = boxes[boxIdToCheck]!

			movedBoxesIds.insert(boxToCheck.id)

			var boxPoint = Point2D(x: boxToCheck.position.moved(to: direction).x, y: boxToCheck.position.y)

			if boxToCheck.horizontalRange.contains(boxPoint.x) {
				boxPoint.move(to: direction)
			}

			if walls.contains(boxPoint) {
				return []
			}

			if let nextBox = boxAt(boxPoint, boxes: boxes), !movedBoxesIds.contains(nextBox.id) {
				boxIdsToCheck.append(nextBox.id)
			}
		}

		return movedBoxesIds
	}

	private func solveFor(startPosition: Point2D, boxes originalBoxes: [Int: Box], walls: Set<Point2D>, instructions: [Direction]) -> Int {
		var position = startPosition
		var boxes = originalBoxes

		for instruction in instructions {
			let nextPosition = position.moved(to: instruction)

			guard !walls.contains(nextPosition) else {
				continue
			}

			if boxAt(nextPosition, boxes: boxes) != nil {
				let boxesToMove: Set<Int>

				if instruction.isHorizontal {
					boxesToMove = horizontallyMovableBoxIds(at: nextPosition, direction: instruction, boxes: boxes, walls: walls)
				} else {
					boxesToMove = verticallyMovableBoxIds(at: nextPosition, direction: instruction, boxes: boxes, walls: walls)
				}

				for boxIdToMove in boxesToMove {
					boxes[boxIdToMove]!.position.move(to: instruction)
				}

				if boxesToMove.isNotEmpty {
					position = nextPosition
				}

			} else {
				position = nextPosition
			}

			// printState(position: position, boxes: boxes, walls: walls)
		}

		return score(boxes: Set(boxes.values.map(\.position)))
	}

	func solvePart1(withInput input: Input) -> Int {
		var boxes: [Int: Box] = [:]

		for (id, box) in input.boxes.enumerated() {
			boxes[id] = .init(id: id, position: box, width: 1)
		}

		return solveFor(startPosition: input.startPosition, boxes: boxes, walls: input.walls, instructions: input.instructions)
	}

	func solvePart2(withInput input: Input) -> Int {
		var boxes: [Int: Box]
		var walls: Set<Point2D>
		var position = input.startPosition

		(boxes, walls, position) = widenMap(boxes: input.boxes, walls: input.walls, startPoint: position)

		return solveFor(startPosition: position, boxes: boxes, walls: walls, instructions: input.instructions)
	}

	func parseInput(rawString: String) -> Input {
		var boxes: Set<Point2D> = []
		var startPosition: Point2D?
		var walls: Set<Point2D> = []
		var instructions: [Direction] = []

		for (y, line) in rawString.allLines().enumerated() {
			for (x, character) in line.enumerated() {
				let point = Point2D(x: x, y: y)

				switch character {
				case "#": walls.insert(point)
				case ".": continue
				case "@": startPosition = point
				case "O": boxes.insert(point)
				case "<": instructions.append(.west)
				case ">": instructions.append(.east)
				case "^": instructions.append(.north)
				case "v": instructions.append(.south)
				default: preconditionFailure()
				}
			}
		}

		return .init(boxes: boxes, startPosition: startPosition!, walls: walls, instructions: instructions)
	}
}
