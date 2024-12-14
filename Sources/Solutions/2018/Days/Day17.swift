import Foundation
import Tools

final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	struct Input {
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
	}

	private func printGrid(_ grid: Grid) {
		for y in grid.yRange {
			var printLine = ""

			for x in grid.xRange {
				let tile = grid.tiles[y][x]

				switch tile {
				case .empty: printLine += "."
				case .wall: printLine += "#"
				case .moving: printLine += "|"
				case .settled: printLine += "~"
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

	private enum Tile: Equatable {
		case empty
		case wall
		case moving
		case settled
	}

	private struct Grid: Equatable {
		let xRange: ClosedRange<Int>
		let yRange: ClosedRange<Int>

		var tiles: [[Tile]]
	}

	@discardableResult
	private func placeGrain(startingAt startPosition: Point2D, direction: Direction, grid: inout Grid) -> Point2D? {
		var currentDirection = direction
		var currentPosition = startPosition

		func isBlocked(point: Point2D) -> Bool {
			(grid.tiles[point.y][point.x] == .wall) || (grid.tiles[point.y][point.x] == .settled)
		}

		while true {
			let newPoint = currentPosition.moved(to: currentDirection)

			if newPoint.y > grid.yRange.upperBound {
				return nil
			}

			if grid.tiles[newPoint.y][newPoint.x] == .moving {
				currentPosition = newPoint
			} else if currentDirection != .south, grid.tiles[currentPosition.y + 1][currentPosition.x] == .moving {
				currentDirection = .south
			} else if isBlocked(point: newPoint) {
				if currentDirection == .south {
					let leftWallPoint = placeGrain(startingAt: currentPosition, direction: .west, grid: &grid)
					let rightWallPoint = placeGrain(startingAt: currentPosition, direction: .east, grid: &grid)

					if let leftWallPoint, let rightWallPoint {
						for x in leftWallPoint.x ... rightWallPoint.x {
							grid.tiles[leftWallPoint.y][x] = .settled
						}
					}

					return nil
				} else if currentDirection == .west || currentDirection == .east {
					return currentPosition
				}
			} else {
				if currentDirection == .south {
					grid.tiles[newPoint.y][newPoint.x] = .moving
				} else {
					let southPoint = newPoint.moved(to: .south)

					grid.tiles[newPoint.y][newPoint.x] = .moving

					if !isBlocked(point: southPoint) {
						grid.tiles[southPoint.y][southPoint.x] = .moving
					}
				}

				return nil
			}
		}
	}

	private var part1Grid: Grid!

	func solvePart1(withInput input: Input) -> Int {
		let lines = input.lines

		let xRange = lines.map(\.minX).min()! ... lines.map(\.maxX).max()!
		let yRange = lines.map(\.minY).min()! ... lines.map(\.maxY).max()!

		var tiles: [[Tile]] = .init(repeating: .init(repeating: .empty, count: xRange.upperBound + 2), count: yRange.upperBound + 2)

		for line in lines {
			switch line {
			case .horizontal(let y, let xRange):
				for x in xRange {
					tiles[y][x] = .wall
				}
			case .vertical(let x, let yRange):
				for y in yRange {
					tiles[y][x] = .wall
				}
			}
		}

		var grid = Grid(xRange: xRange, yRange: yRange, tiles: tiles)

		var oldTiles = grid.tiles

		while true {
			placeGrain(startingAt: input.spring, direction: .south, grid: &grid)

			if oldTiles == grid.tiles {
				part1Grid = grid

				var sum = 0

				for y in grid.yRange {
					for x in grid.xRange.lowerBound - 1 ... grid.xRange.upperBound + 1 {
						let tile = grid.tiles[y][x]

						switch tile {
						case .empty,
						     .wall: break
						case .moving,
						     .settled: sum += 1
						}
					}
				}

				return sum
			}

			oldTiles = grid.tiles
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		var sum = 0

		for y in part1Grid.yRange {
			for x in part1Grid.xRange.lowerBound - 1 ... part1Grid.xRange.upperBound + 1 {
				let tile = part1Grid.tiles[y][x]

				switch tile {
				case .empty,
				     .wall,
				     .moving: break
				case .settled: sum += 1
				}
			}
		}

		return sum
	}

	func parseInput(rawString: String) -> Input {
		let lines: [Line] = rawString.allLines().map { line in
			if let arguments = line.getCapturedValues(pattern: #"x=([0-9]*), y=([Z0-9]*)..([0-9]*)"#) {
				.vertical(x: Int(arguments[0])!, y: Int(arguments[1])! ... Int(arguments[2])!)
			} else if let arguments = line.getCapturedValues(pattern: #"y=([0-9]*), x=([Z0-9]*)..([0-9]*)"#) {
				.horizontal(y: Int(arguments[0])!, x: Int(arguments[1])! ... Int(arguments[2])!)
			} else {
				preconditionFailure()
			}
		}

		return .init(lines: lines, spring: .init(x: 500, y: 0))
	}
}
