import Foundation
import Tools

final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	let expectedPart1Result = 29063
	let expectedPart2Result = 23811

	private var input: Input!

	private struct Input {
		let lines: [Line]
		let spring: Point2D
	}

	private enum Line {
		case vertical(x: Int, y: ClosedRange<Int>)
		case horizontal(y: Int, x: ClosedRange<Int>)

		var minX: Int {
			switch self {
			case .vertical(let x, _): x
			case .horizontal(_, let x): x.lowerBound
			}
		}

		var maxX: Int {
			switch self {
			case .vertical(let x, _): x
			case .horizontal(_, let x): x.upperBound
			}
		}

		var minY: Int {
			switch self {
			case .vertical(_, let y): y.lowerBound
			case .horizontal(let y, _): y
			}
		}

		var maxY: Int {
			switch self {
			case .vertical(_, let y): y.upperBound
			case .horizontal(let y, _): y
			}
		}

		func intersects(point: Point2D) -> Bool {
			switch self {
			case .vertical(let x, let y): x == point.x && y.contains(point.y)
			case .horizontal(let y, let x): y == point.y && x.contains(point.x)
			}
		}
	}

	private func printState(_ state: State, grid: Grid) {
		for y in grid.yRange {
			var printLine = ""

			for x in grid.xRange {
				let point = Point2D(x: x, y: y)

				if grid.lines.contains(where: { $0.intersects(point: point) }) {
					printLine += "#"
				} else {
					if state.settledSand.contains(point) {
						printLine += "~"
					} else if state.movingSand.contains(point) {
						printLine += "|"
					} else {
						printLine += "."
					}
				}
			}

			print(printLine)
		}

		print("---")
	}

	private struct MovingSand: Hashable {
		let position: Point2D
		let direction: Direction
	}

	private struct State: Hashable {
		var movingSand: Set<Point2D> = []
		var settledSand: Set<Point2D> = []
	}

	private struct Grid {
		let lines: [Line]

		let xRange: ClosedRange<Int>
		let yRange: ClosedRange<Int>

		let walls: Set<Point2D>
	}

	@discardableResult
	private func placeGrain(startingAt startPosition: Point2D, direction: Direction, state: inout State, grid: Grid) -> Point2D? {
		var currentDirection = direction
		var currentPosition = startPosition

		func isBlocked(point: Point2D) -> Bool {
			state.settledSand.contains(point) || grid.walls.contains(point)
		}

		while true {
			let newPoint = currentPosition.moved(to: currentDirection)

			if newPoint.y > grid.yRange.upperBound {
				return nil
			}

			if state.movingSand.contains(newPoint) {
				currentPosition = newPoint
			} else if currentDirection != .south, state.movingSand.contains(currentPosition.moved(to: .south)) {
				currentDirection = .south
			} else if isBlocked(point: newPoint) {
				if currentDirection == .south {
					let leftWallPoint = placeGrain(startingAt: currentPosition, direction: .west, state: &state, grid: grid)
					let rightWallPoint = placeGrain(startingAt: currentPosition, direction: .east, state: &state, grid: grid)

					if let leftWallPoint, let rightWallPoint {
						for x in leftWallPoint.x ... rightWallPoint.x {
							let point = Point2D(x: x, y: leftWallPoint.y)

							state.settledSand.insert(point)
							state.movingSand.remove(point)
						}
					}

					return nil
				} else if currentDirection == .west {
					return currentPosition
				} else if currentDirection == .east {
					return currentPosition
				}
			} else {
				if currentDirection == .west || currentDirection == .east {
					let southPoint = newPoint.moved(to: .south)

					if isBlocked(point: southPoint) {
						state.movingSand.insert(newPoint)

						return nil
					} else {
						state.movingSand.insert(newPoint)
						state.movingSand.insert(southPoint)

						return nil
					}
				} else {
					state.movingSand.insert(newPoint)

					return nil
				}
			}
		}
	}

	private var part1EndState: State!

	func solvePart1() -> Int {
		let lines = input.lines

		let xRange = lines.map(\.minX).min()! ... lines.map(\.maxX).max()!
		let yRange = lines.map(\.minY).min()! ... lines.map(\.maxY).max()!

		var walls: Set<Point2D> = []

		for line in lines {
			switch line {
			case .horizontal(let y, let xRange):
				for x in xRange {
					walls.insert(.init(x: x, y: y))
				}
			case .vertical(let x, let yRange):
				for y in yRange {
					walls.insert(.init(x: x, y: y))
				}
			}
		}

		var state = State()
		let grid = Grid(lines: lines, xRange: xRange, yRange: yRange, walls: walls)

		var oldState = state

		while true {
			placeGrain(startingAt: input.spring, direction: .south, state: &state, grid: grid)

			if state == oldState {
				part1EndState = state

				return state.movingSand.filter { yRange.contains($0.y) }.count + state.settledSand.filter { yRange.contains($0.y) }.count
			}

			oldState = state
		}
	}

	func solvePart2() -> Int {
		let lines = input.lines

		let yRange = lines.map(\.minY).min()! ... lines.map(\.maxY).max()!

		return part1EndState.settledSand.filter { yRange.contains($0.y) }.count
	}

	func parseInput(rawString: String) {
		let lines: [Line] = rawString.allLines().map { line in
			if let arguments = line.getCapturedValues(pattern: #"x=([0-9]*), y=([Z0-9]*)..([0-9]*)"#) {
				.vertical(x: Int(arguments[0])!, y: Int(arguments[1])! ... Int(arguments[2])!)
			} else if let arguments = line.getCapturedValues(pattern: #"y=([0-9]*), x=([Z0-9]*)..([0-9]*)"#) {
				.horizontal(y: Int(arguments[0])!, x: Int(arguments[1])! ... Int(arguments[2])!)
			} else {
				preconditionFailure()
			}
		}

		input = .init(lines: lines, spring: .init(x: 500, y: 0))
	}
}
