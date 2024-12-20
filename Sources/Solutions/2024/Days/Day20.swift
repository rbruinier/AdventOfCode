import Foundation
import Tools

final class Day20Solver: DaySolver {
	let dayNumber: Int = 20

	struct Input {
		let grid: Grid2D<Tile>
		let start: Point2D
		let end: Point2D
	}

	enum Tile: Equatable {
		case empty
		case wall
	}

	private struct Cheat {
		let start: Point2D
		let end: Point2D
	}

	/// Find possible cheats by checking next two points in 4 directions making sure a wall is in between given point and next point
	private func findPossibleCheats(in grid: Grid2D<Tile>, path: [Point2D]) -> [Cheat] {
		var cheats: [Cheat] = []

		for i in 0 ..< path.count {
			for j in i + 1 ..< path.count {
				let a = path[i]
				let b = path[j]

				if a.x == b.x, abs(a.y - b.y) == 2 {
					if a.y < b.y {
						if grid[Point2D(x: a.x, y: a.y + 1)] == .wall {
							cheats.append(.init(start: a, end: b))
						}
					} else {
						if grid[Point2D(x: a.x, y: a.y - 1)] == .wall {
							cheats.append(.init(start: a, end: b))
						}
					}
				} else if a.y == b.y, abs(a.x - b.x) == 2 {
					if a.x < b.x {
						if grid[Point2D(x: a.x + 1, y: a.y)] == .wall {
							cheats.append(.init(start: a, end: b))
						}
					} else {
						if grid[Point2D(x: a.x - 1, y: a.y)] == .wall {
							cheats.append(.init(start: a, end: b))
						}
					}
				}
			}
		}

		return cheats
	}

	/// Just walk the path from the start, we can only go one way (there are no forks) so no need for a floodf fill type algorithm
	private func findPath(in grid: Grid2D<Tile>, start: Point2D, end: Point2D) -> [Point2D] {
		var point = start
		var path: [Point2D] = [start]
		var visitedPoints: Set<Point2D> = [start]

		while point != end {
			for direction in Direction.allStraight {
				let newPoint = point.moved(to: direction)

				if !visitedPoints.contains(newPoint), let tile = grid[safe: newPoint], tile != .wall {
					path.append(newPoint)
					visitedPoints.insert(newPoint)

					point = newPoint

					break
				}
			}
		}

		return path
	}

	private func savingsWithCheat(_ cheat: Cheat, in path: [Point2D]) -> Int? {
		guard
			let indexOfStartPoint = path.firstIndex(where: { $0 == cheat.start }),
			let indexOfEndPoint = path.firstIndex(where: { $0 == cheat.end })
		else {
			return nil
		}

		guard indexOfStartPoint < indexOfEndPoint else {
			return nil
		}

		return indexOfEndPoint - indexOfStartPoint - 1
	}

	func solvePart1(withInput input: Input) -> Int {
		let path = findPath(in: input.grid, start: input.start, end: input.end)

		let cheats = findPossibleCheats(in: input.grid, path: path)

		var result = 0

		for cheat in cheats {
			guard let savings = savingsWithCheat(cheat, in: path) else {
				continue
			}

			if savings >= 100 {
				result += 1
			}
		}

		return result
	}

	func solvePart2(withInput input: Input) -> Int {
		let path = findPath(in: input.grid, start: input.start, end: input.end)

		var result = 0

		// This is actually easier than part 1 because we don't care about walls so the shortest distance is just the manhattan distance.
		for i in 0 ..< path.count {
			for j in i + 1 ..< path.count {
				let a = path[i]
				let b = path[j]

				let distance = b.manhattanDistance(from: a)

				let savings = (j - i) - distance

				if distance <= 20, savings >= 100 {
					result += 1
				}
			}
		}

		return result
	}

	func parseInput(rawString: String) -> Input {
		var start: Point2D = .zero
		var end: Point2D = .zero

		let grid: Grid2D<Tile> = rawString.parseGrid2D { character, point in
			switch character {
			case "S":
				start = point
				return .empty
			case "E":
				end = point
				return .empty
			case ".":
				return .empty
			case "#":
				return .wall
			default: preconditionFailure()
			}
		}

		return .init(grid: grid, start: start, end: end)
	}
}
