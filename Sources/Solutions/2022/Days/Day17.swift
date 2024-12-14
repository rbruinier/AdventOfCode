import Foundation
import Tools

/// Part 1 just plays the "tetris" game and takes the highest point as a result.
///
/// In part 2 we play the game for 10.000 rocks and scan for a repeating cycle in the placed rocks by keeping track of x position, shape index and jet direction index per dropped rock.
/// We also keep track of the total height for each rock dropped. After that some basic calculations return the total height for the requested number of rocks:
///
/// Result = total height till first cycle + ((1.000.000.000.000 - rock index of first cycle starting point) * height of cycle) + remaining height
final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	struct Input {
		let shapes: [Shape]
		let jetDirections: [JetDirection]
	}

	enum JetDirection {
		case left
		case right
	}

	struct Shape {
		var points: [Point2D]

		let xRange: ClosedRange<Int>
		let yRange: ClosedRange<Int>

		let width: Int
		let height: Int

		init(points: [Point2D]) {
			self.points = points

			xRange = points.map(\.x).min()! ... points.map(\.x).max()!
			yRange = points.map(\.y).min()! ... points.map(\.y).max()!

			width = (xRange.upperBound - xRange.lowerBound) + 1
			height = (yRange.upperBound - yRange.lowerBound) + 1
		}

		func horizontalRangeAtPosition(_ position: Point2D) -> ClosedRange<Int> {
			xRange.lowerBound + position.x ... xRange.upperBound + position.x
		}

		func verticalRangeAtPosition(_ position: Point2D) -> ClosedRange<Int> {
			yRange.lowerBound + position.y ... yRange.upperBound + position.y
		}

		func canMoveHorizontallyToPosition(_ position: Point2D, occupiedPositions: Set<Point2D>) -> Bool {
			let range = horizontalRangeAtPosition(position)

			return (0 ... 6).contains(range) && overlapsOccupiedPosition(at: position, occupiedPositions: occupiedPositions) == false
		}

		func canMoveVerticallyToPosition(_ position: Point2D, occupiedPositions: Set<Point2D>) -> Bool {
			let range = verticalRangeAtPosition(position)

			return (range.upperBound < 0) && overlapsOccupiedPosition(at: position, occupiedPositions: occupiedPositions) == false
		}

		func overlapsOccupiedPosition(at position: Point2D, occupiedPositions: Set<Point2D>) -> Bool {
			for point in points {
				if occupiedPositions.contains(point + position) {
					return true
				}
			}

			return false
		}

		func addPiecesToOccupiedPositions(_ occupiedPositions: inout Set<Point2D>, at position: Point2D) {
			for point in points {
				let piecePosition = point + position

				occupiedPositions.insert(piecePosition)
			}
		}
	}

	private struct GameResult {
		struct RockData: Equatable {
			let shapeIndex: Int
			let jetDirectionIndex: Int
			let x: Int
		}

		let occupiedPositions: Set<Point2D>
		let dataPerRock: [Int: RockData]
		let heightPerDroppedRock: [Int: Int]
	}

	init() {}

	private func runGame(withRockCount maxRockCount: Int, shapes: [Shape], jetDirections: [JetDirection]) -> GameResult {
		var occupiedPositions: Set<Point2D> = []

		var dataPerRock: [Int: GameResult.RockData] = [:]
		var heightPerDroppedRock: [Int: Int] = [:]

		var jetDirectionIndex = 0
		var shapeIndex = 0
		var currentTopPositionY = 0

		var rockCounter = 0

		gameLoop: while rockCounter < maxRockCount {
			let currentShape = shapes[shapeIndex]
			var currentPosition = Point2D(x: 2, y: currentTopPositionY - 3 - currentShape.height)

			shapeLoop: while true {
				let direction = jetDirections[jetDirectionIndex]

				jetDirectionIndex = (jetDirectionIndex + 1) % jetDirections.count

				var newPosition = currentPosition

				switch direction {
				case .left: newPosition = newPosition.moved(to: .west)
				case .right: newPosition = newPosition.moved(to: .east)
				}

				if currentShape.canMoveHorizontallyToPosition(newPosition, occupiedPositions: occupiedPositions) {
					currentPosition = newPosition
				}

				if currentShape.canMoveVerticallyToPosition(currentPosition + .init(x: 0, y: 1), occupiedPositions: occupiedPositions) {
					currentPosition.y += 1
				} else {
					currentShape.addPiecesToOccupiedPositions(&occupiedPositions, at: currentPosition)
					currentTopPositionY = min(currentPosition.y, currentTopPositionY)

					dataPerRock[rockCounter] = .init(shapeIndex: shapeIndex, jetDirectionIndex: jetDirectionIndex, x: currentPosition.x)
					heightPerDroppedRock[rockCounter] = -currentPosition.y

					rockCounter += 1

					break
				}
			}

			shapeIndex = (shapeIndex + 1) % shapes.count
		}

		return .init(occupiedPositions: occupiedPositions, dataPerRock: dataPerRock, heightPerDroppedRock: heightPerDroppedRock)
	}

	func solvePart1(withInput input: Input) -> Int {
		let result = runGame(withRockCount: 2022, shapes: input.shapes, jetDirections: input.jetDirections)

		let minY = result.occupiedPositions.map(\.y).min()!

		return -minY
	}

	func solvePart2(withInput input: Input) -> Int {
		let result = runGame(withRockCount: 10000, shapes: input.shapes, jetDirections: input.jetDirections)

		var repetition: (startIndex: Int, size: Int)?

		startIndexLoop: for startIndex in 1 ..< 10000 {
			repeatSizeLoop: for repeatSize in 1000 ..< 5000 {
				var isIdentical = true

				scanLoop: for scanIndex in startIndex ..< startIndex + repeatSize {
					let scanIndex2 = scanIndex + repeatSize

					guard result.dataPerRock[scanIndex] != nil, result.dataPerRock[scanIndex2] != nil else {
						isIdentical = false

						break scanLoop
					}

					if result.dataPerRock[scanIndex] != result.dataPerRock[scanIndex2] {
						isIdentical = false

						break scanLoop
					}
				}

				if isIdentical {
					repetition = (startIndex: startIndex, size: repeatSize)

					break startIndexLoop
				}
			}
		}

		guard let repetition else {
			fatalError()
		}

		let totalRockCount = 1_000_000_000_000

		let heightBeforeCycle = result.heightPerDroppedRock[repetition.startIndex]!
		let cycleHeight = result.heightPerDroppedRock[repetition.startIndex + repetition.size]! - result.heightPerDroppedRock[repetition.startIndex]!

		let numberOfCycles = (totalRockCount - repetition.startIndex) / repetition.size
		let remainingRocks = totalRockCount - (numberOfCycles * repetition.size) - repetition.startIndex

		let remainingHeight = result.heightPerDroppedRock[repetition.startIndex + remainingRocks]! - result.heightPerDroppedRock[repetition.startIndex]!

		return heightBeforeCycle + (cycleHeight * numberOfCycles) + remainingHeight - 1
	}

	func parseInput(rawString: String) -> Input {
		let shapes: [Shape] = [
			.init(points: [
				.init(x: 0, y: 0),
				.init(x: 1, y: 0),
				.init(x: 2, y: 0),
				.init(x: 3, y: 0),
			]),
			.init(points: [
				.init(x: 1, y: 0),
				.init(x: 0, y: 1),
				.init(x: 1, y: 1),
				.init(x: 2, y: 1),
				.init(x: 1, y: 2),
			]),
			.init(points: [
				.init(x: 2, y: 0),
				.init(x: 2, y: 1),
				.init(x: 0, y: 2),
				.init(x: 1, y: 2),
				.init(x: 2, y: 2),
			]),
			.init(points: [
				.init(x: 0, y: 0),
				.init(x: 0, y: 1),
				.init(x: 0, y: 2),
				.init(x: 0, y: 3),
			]),
			.init(points: [
				.init(x: 0, y: 0),
				.init(x: 1, y: 0),
				.init(x: 0, y: 1),
				.init(x: 1, y: 1),
			]),
		]

		let jetDirections: [JetDirection] = rawString.compactMap {
			switch $0 {
			case "<": .left
			case ">": .right
			default: nil
			}
		}

		return .init(shapes: shapes, jetDirections: jetDirections)
	}
}
