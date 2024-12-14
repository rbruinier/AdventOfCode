import Foundation
import Tools

final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	struct Input {
		var grid: [Point2D: Bool]
	}

	private func updateGridPart01(_ originalGrid: [Point2D: Bool]) -> [Point2D: Bool] {
		var grid = originalGrid

		for y in 0 ..< 5 {
			for x in 0 ..< 5 {
				let point = Point2D(x: x, y: y)

				var count = 0
				for neighbor in point.neighbors() {
					count += originalGrid[neighbor, default: false] == true ? 1 : 0
				}

				if originalGrid[point]! {
					grid[point] = count == 1 ? true : false
				} else {
					grid[point] = (count == 1 || count == 2) ? true : false
				}
			}
		}

		return grid
	}

	private func updateGridPart02(_ originalGrids: [Int: [Point2D: Bool]]) -> [Int: [Point2D: Bool]] {
		var grids = originalGrids

		let minLevel = originalGrids.keys.min()! - 1
		let maxLevel = originalGrids.keys.max()! + 1

		let defaultGrid: [Point2D: Bool] = [:]
		let centerPoint = Point2D(x: 2, y: 2)

		for level in minLevel ... maxLevel {
			let nextLevel = level + 1
			let previousLevel = level - 1

			for y in 0 ..< 5 {
				for x in 0 ..< 5 {
					let point = Point2D(x: x, y: y)

					guard point != centerPoint else {
						continue
					}

					var count = 0
					for neighbor in point.neighbors() {
						if neighbor == .init(x: 2, y: 2) {
							// go a level deeper
							if point.x == 3 {
								for innerY in 0 ..< 5 {
									count += originalGrids[nextLevel, default: defaultGrid][.init(x: 4, y: innerY)] == true ? 1 : 0
								}
							} else if point.x == 1 {
								for innerY in 0 ..< 5 {
									count += originalGrids[nextLevel, default: defaultGrid][.init(x: 0, y: innerY)] == true ? 1 : 0
								}
							} else if point.y == 3 {
								for innerX in 0 ..< 5 {
									count += originalGrids[nextLevel, default: defaultGrid][.init(x: innerX, y: 4)] == true ? 1 : 0
								}
							} else if point.y == 1 {
								for innerX in 0 ..< 5 {
									count += originalGrids[nextLevel, default: defaultGrid][.init(x: innerX, y: 0)] == true ? 1 : 0
								}
							} else {
								fatalError()
							}
						} else if neighbor.y == -1 {
							count += originalGrids[previousLevel, default: defaultGrid][.init(x: 2, y: 1)] == true ? 1 : 0
						} else if neighbor.y == 5 {
							count += originalGrids[previousLevel, default: defaultGrid][.init(x: 2, y: 3)] == true ? 1 : 0
						} else if neighbor.x == -1 {
							count += originalGrids[previousLevel, default: defaultGrid][.init(x: 1, y: 2)] == true ? 1 : 0
						} else if neighbor.x == 5 {
							count += originalGrids[previousLevel, default: defaultGrid][.init(x: 3, y: 2)] == true ? 1 : 0
						} else {
							count += originalGrids[level, default: defaultGrid][neighbor, default: false] == true ? 1 : 0
						}
					}

					if originalGrids[level, default: defaultGrid][point, default: false] {
						grids[level]![point] = count == 1 ? true : false
					} else {
						grids[level, default: defaultGrid][point] = (count == 1 || count == 2) ? true : false
					}
				}
			}
		}

		return grids
	}

	private func calculateBiodiversityRating(for grid: [Point2D: Bool]) -> Int {
		var rating = 0

		var shifter = 0
		for y in 0 ..< 5 {
			for x in 0 ..< 5 {
				if grid[Point2D(x: x, y: y)]! {
					rating |= 1 << shifter
				}

				shifter += 1
			}
		}

		return rating
	}

	func solvePart1(withInput input: Input) -> Int {
		var grid = input.grid

		var pastHashes: Set<Int> = Set()
		while true {
			grid = updateGridPart01(grid)

			let hashValue = grid.hashValue

			if pastHashes.contains(hashValue) {
				return calculateBiodiversityRating(for: grid)
			} else {
				pastHashes.insert(hashValue)
			}
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		var grids: [Int: [Point2D: Bool]] = [0: input.grid]

		for _ in 0 ..< 200 {
			grids = updateGridPart02(grids)
		}

		var sum = 0
		for grid in grids.values {
			sum += grid.values.filter { $0 == true }.count
		}

		return sum
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines()

		var grid: [Point2D: Bool] = [:]
		for y in 0 ..< 5 {
			let line = lines[y]

			for x in 0 ..< 5 {
				grid[.init(x: x, y: y)] = line[x ... x] == "#" ? true : false
			}
		}

		return .init(grid: grid)
	}
}
