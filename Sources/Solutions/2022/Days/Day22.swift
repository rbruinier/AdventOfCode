import Foundation
import Tools

/// For part 2 I made a small cube out of paper. Each side with an identifier and A, B, C and D side markings (in the 2D map orientation). Using this map hardcoded
/// transformations are configured for when a point should move to a new side.
///
/// Probably could be solved more elegantly but it works (for this input)
final class Day22Solver: DaySolver {
	let dayNumber: Int = 22

	private var input: Input!

	private struct Input {
		let tiles: [Point2D: Tile]
		let moves: [Move]
	}

	private enum Tile {
		case floor
		case wall
	}

	private struct Move {
		let steps: Int
		let turn: Point2D.Degrees
	}

	private struct MapData {
		let boundingBox: Rect

		var rangesPerX: [Int: ClosedRange<Int>] = [:]
		var rangesPerY: [Int: ClosedRange<Int>] = [:]
	}

	private struct Side: Hashable {
		let cubeSide: Int
		let sideIndex: Int

		init(_ cubeSide: Int, _ sideIndex: Int) {
			self.cubeSide = cubeSide
			self.sideIndex = sideIndex
		}
	}

	private struct SideTranslation {
		let cubeSide: Int
		let sideIndex: Int

		let rotate: Point2D.Degrees

		let transform: (_ point: Point2D, _ sideSize: Int) -> Point2D

		init(_ cubeSide: Int, _ sideIndex: Int, _ rotate: Point2D.Degrees, transform: ((_ point: Point2D, _ sideSize: Int) -> Point2D)? = nil) {
			self.cubeSide = cubeSide
			self.sideIndex = sideIndex

			self.rotate = rotate
			self.transform = transform ?? { p, _ in p }
		}
	}

	init() {}

	private func createMapData(from tiles: [Point2D: Tile]) -> MapData {
		let boundingBox = Rect(
			origin: .init(
				x: 0,
				y: 0
			),
			size: .init(
				width: tiles.keys.map(\.x).max()!,
				height: tiles.keys.map(\.y).max()!
			)
		)

		var rangesPerX: [Int: ClosedRange<Int>] = [:]
		var rangesPerY: [Int: ClosedRange<Int>] = [:]

		for x in boundingBox.topLeft.x ... boundingBox.bottomRight.x {
			let ys = tiles.keys.filter { $0.x == x }.map(\.y)

			rangesPerX[x] = ys.min()! ... ys.max()!
		}

		for y in boundingBox.topLeft.y ... boundingBox.bottomRight.y {
			let xs = tiles.keys.filter { $0.y == y }.map(\.x)

			rangesPerY[y] = xs.min()! ... xs.max()!
		}

		return .init(boundingBox: boundingBox, rangesPerX: rangesPerX, rangesPerY: rangesPerY)
	}

	private func scoreFor(point: Point2D, direction: Direction) -> Int {
		let facingPoints: Int

		switch direction {
		case .east: facingPoints = 0
		case .south: facingPoints = 1
		case .west: facingPoints = 2
		case .north: facingPoints = 3
		default: fatalError()
		}

		return (point.y + 1) * 1000 + (point.x + 1) * 4 + facingPoints
	}

	func solvePart1() -> Int {
		let tiles = input.tiles
		let moves = input.moves

		let mapData = createMapData(from: tiles)

		var point = Point2D(x: 0, y: 0)
		var direction = Direction.east

		for move in moves {
			for _ in 0 ..< move.steps {
				var newPoint = point.moved(to: direction)

				if tiles.keys.contains(newPoint) == false {
					switch direction {
					case .east:
						newPoint.x = mapData.rangesPerY[newPoint.y]!.lowerBound
					case .west:
						newPoint.x = mapData.rangesPerY[newPoint.y]!.upperBound
					case .north:
						newPoint.y = mapData.rangesPerX[newPoint.x]!.upperBound
					case .south:
						newPoint.y = mapData.rangesPerX[newPoint.x]!.lowerBound
					default:
						fatalError()
					}
				}

				if tiles[newPoint]! == .wall {
					break
				}

				point = newPoint
			}

			direction = direction.turned(degrees: move.turn)
		}

		return scoreFor(point: point, direction: direction)
	}

	func solvePart2() -> Int {
		let a = 0
		let b = 1
		let c = 2
		let d = 3

		let sideMappings: [Side: SideTranslation] = [
			.init(0, a): .init(5, b, .ninety, transform: { p, _ in Point2D(x: 0, y: p.x) }),
			.init(0, b): .init(4, b, .oneEighty, transform: { p, width in Point2D(x: 0, y: width - p.y) }),
			.init(0, c): .init(1, b, .zero),
			.init(0, d): .init(2, a, .zero),

			.init(1, a): .init(5, d, .zero, transform: { p, width in Point2D(x: p.x, y: width) }),
			.init(1, b): .init(0, c, .zero),
			.init(1, c): .init(3, c, .oneEighty, transform: { p, width in Point2D(x: width, y: width - p.y) }),
			.init(1, d): .init(2, c, .ninety, transform: { p, width in Point2D(x: width, y: p.x) }),

			.init(2, a): .init(0, d, .zero),
			.init(2, b): .init(4, a, .twoSeventy, transform: { p, _ in Point2D(x: p.y, y: 0) }),
			.init(2, c): .init(1, d, .twoSeventy, transform: { p, width in Point2D(x: p.y, y: width) }),
			.init(2, d): .init(3, a, .zero),

			.init(3, a): .init(2, d, .zero),
			.init(3, b): .init(4, c, .zero),
			.init(3, c): .init(1, c, .oneEighty, transform: { p, width in Point2D(x: width, y: width - p.y) }),
			.init(3, d): .init(5, c, .ninety, transform: { p, width in Point2D(x: width, y: p.x) }),

			.init(4, a): .init(2, b, .ninety, transform: { p, _ in Point2D(x: 0, y: p.x) }),
			.init(4, b): .init(0, b, .oneEighty, transform: { p, width in Point2D(x: 0, y: width - p.y) }),
			.init(4, c): .init(3, b, .zero),
			.init(4, d): .init(5, a, .zero),

			.init(5, a): .init(4, d, .zero),
			.init(5, b): .init(0, a, .twoSeventy, transform: { p, _ in Point2D(x: p.y, y: 0) }),
			.init(5, c): .init(3, d, .twoSeventy, transform: { p, width in Point2D(x: p.y, y: width) }),
			.init(5, d): .init(1, a, .zero, transform: { p, _ in Point2D(x: p.x, y: 0) }),
		]

		let size = 50

		let sideSize = Size(width: size, height: size)

		let sideBoundingBoxes: [Rect] = [
			.init(origin: .init(x: 1 * size, y: 0 * size), size: sideSize),
			.init(origin: .init(x: 2 * size, y: 0 * size), size: sideSize),
			.init(origin: .init(x: 1 * size, y: 1 * size), size: sideSize),
			.init(origin: .init(x: 1 * size, y: 2 * size), size: sideSize),
			.init(origin: .init(x: 0 * size, y: 2 * size), size: sideSize),
			.init(origin: .init(x: 0 * size, y: 3 * size), size: sideSize),
		]

		func sideIndexForPoint(_ point: Point2D) -> Int {
			guard let sideBoundingBoxIndex = sideBoundingBoxes.firstIndex(where: { $0.contains(point: point) }) else {
				fatalError()
			}

			return sideBoundingBoxIndex
		}

		let tiles = input.tiles
		let moves = input.moves

		var point = Point2D(x: 0, y: 0)
		var direction = Direction.east

		for move in moves {
			let moveStartingFromValidTile = tiles.keys.contains(point)

			for _ in 0 ..< move.steps {
				var newPoint = point.moved(to: direction)
				var newDirection = direction

				if moveStartingFromValidTile, tiles.keys.contains(newPoint) == false {
					let currentSide = sideIndexForPoint(point)
					let currentSideBoundingBox = sideBoundingBoxes[currentSide]

					let sideIndex: Int

					switch direction {
					case .north: sideIndex = a
					case .east: sideIndex = c
					case .west: sideIndex = b
					case .south: sideIndex = d
					default: fatalError()
					}

					let newSide = sideMappings[.init(currentSide, sideIndex)]!
					let newSideBoundingBox = sideBoundingBoxes[newSide.cubeSide]

					newPoint = newSide.transform(point - currentSideBoundingBox.topLeft, newSideBoundingBox.size.width - 1) + newSideBoundingBox.topLeft

					newDirection = direction.turned(degrees: newSide.rotate)
				}

				if tiles[newPoint] == .wall {
					break
				}

				point = newPoint
				direction = newDirection
			}

			direction = direction.turned(degrees: move.turn)
		}

		return scoreFor(point: point, direction: direction)
	}

	func parseInput(rawString: String) {
		var parseMap = true

		var tiles: [Point2D: Tile] = [:]
		var moves: [Move] = []

		var y = 0
		for line in rawString.allLines(includeEmpty: true) {
			if line.isEmpty {
				parseMap = false

				continue
			}

			if parseMap {
				for (x, char) in line.enumerated() {
					switch char {
					case " ":
						continue
					case ".":
						tiles[.init(x: x, y: y)] = .floor
					case "#":
						tiles[.init(x: x, y: y)] = .wall
					default:
						fatalError()
					}
				}
				y += 1
			} else {
				var currentSteps = 0
				for char in line {
					if let digit = Int(String(char)) {
						currentSteps = (currentSteps * 10) + digit
					} else {
						switch char {
						case "L":
							moves.append(.init(steps: currentSteps, turn: .twoSeventy))
						case "R":
							moves.append(.init(steps: currentSteps, turn: .ninety))
						default:
							fatalError()
						}

						currentSteps = 0
					}
				}

				if currentSteps > 0 {
					moves.append(.init(steps: currentSteps, turn: .zero))
				}
			}
		}

		input = .init(tiles: tiles, moves: moves)
	}
}
