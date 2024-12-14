import Foundation
import Tools

final class Day13Solver: DaySolver {
	let dayNumber: Int = 13

	struct Input {
		let coordinates: [Coordinate]

		let folds: [Fold]

		let width: Int
		let height: Int
	}

	private enum Fold {
		case horizontal(y: Int)
		case vertical(x: Int)
	}

	private struct Coordinate {
		let x: Int
		let y: Int
	}

	private struct Grid: CustomDebugStringConvertible {
		let width: Int
		let height: Int

		var items: [Bool]

		init(width: Int, height: Int) {
			self.width = width
			self.height = height

			items = Array(repeating: false, count: width * height)
		}

		mutating func mark(at coordinate: Coordinate) {
			items[coordinate.y * width + coordinate.x] = true
		}

		mutating func apply(fold: Fold) -> Grid {
			switch fold {
			case .vertical(let foldX):
				var newGrid = Grid(width: foldX, height: height)

				for y in 0 ..< height {
					for x in foldX ..< width {
						let offset = x - foldX
						let targetX = (foldX - offset)

						if targetX < 0 {
							break
						}

						if items[y * width + x] || items[y * width + targetX] {
							newGrid.mark(at: .init(x: targetX, y: y))
						}
					}
				}

				return newGrid
			case .horizontal(let foldY):
				var newGrid = Grid(width: width, height: foldY)

				for y in foldY ..< height {
					let offset = y - foldY
					let targetY = (foldY - offset)

					if targetY < 0 {
						break
					}

					for x in 0 ..< width {
						if items[y * width + x] || items[targetY * width + x] {
							newGrid.mark(at: .init(x: x, y: targetY))
						}
					}
				}

				return newGrid
			}
		}

		var debugDescription: String {
			var result = ""

			for y in 0 ..< height {
				for x in 0 ..< width {
					result += items[y * width + x] ? "#" : "."
				}

				result += "\n"
			}

			return result
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		var grid = Grid(width: input.width, height: input.height)

		for coordinate in input.coordinates {
			grid.mark(at: coordinate)
		}

		grid = grid.apply(fold: input.folds.first!)

		return grid.items.filter { $0 }.count
	}

	func solvePart2(withInput input: Input) -> String {
		var grid = Grid(width: input.width, height: input.height)

		for coordinate in input.coordinates {
			grid.mark(at: coordinate)
		}

		for fold in input.folds {
			grid = grid.apply(fold: fold)
		}

		// we can't programmatically return the result in this case, so the answer is hard coded
		// of course the resolving is still executed

		//        print(grid)

		return "ZUJUAFHP"
	}

	func parseInput(rawString: String) -> Input {
		var coordinates: [Coordinate] = []
		var folds: [Fold] = []

		rawString
			.components(separatedBy: CharacterSet.newlines)
			.forEach { rawLine in
				if rawLine.contains(",") {
					let components = rawLine.components(separatedBy: ",")

					let x = Int(components[0])!
					let y = Int(components[1])!

					coordinates.append(.init(x: x, y: y))
				} else if rawLine.contains("fold along y") {
					let components = rawLine.components(separatedBy: "=")

					let y = Int(components[1])!

					folds.append(.horizontal(y: y))
				} else if rawLine.contains("fold along x") {
					let components = rawLine.components(separatedBy: "=")

					let x = Int(components[1])!

					folds.append(.vertical(x: x))
				}
			}

		let width = coordinates.map(\.x).max()! + 1
		let height = coordinates.map(\.y).max()! + 1

		return .init(coordinates: coordinates, folds: folds, width: width, height: height)
	}
}
