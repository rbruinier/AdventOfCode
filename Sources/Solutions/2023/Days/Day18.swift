import Collections
import Foundation
import Tools

final class Day18Solver: DaySolver {
	let dayNumber: Int = 18

	struct Input {
		let moves: [Move]
	}

	struct Move {
		let direction: Direction
		let steps: Int
		let part2Direction: Direction
		let part2Steps: Int
	}

	func solvePart1(withInput input: Input) -> Int {
		var point: Point2D = .zero
		var points: [Point2D] = [point]

		for move in input.moves {
			point = point.moved(to: move.direction, steps: move.steps)

			points.append(point)
		}

		return Shoelace.calculateArea(of: points)
	}

	func solvePart2(withInput input: Input) -> Int {
		var point: Point2D = .zero
		var points: [Point2D] = [point]

		for move in input.moves {
			point = point.moved(to: move.part2Direction, steps: move.part2Steps)

			points.append(point)
		}

		return Shoelace.calculateArea(of: points)
	}

	func parseInput(rawString: String) -> Input {
		return .init(moves: rawString.allLines().map { line in
			let components = line.components(separatedBy: .whitespaces)

			let direction: Direction

			switch components[0] {
			case "U": direction = .north
			case "D": direction = .south
			case "R": direction = .east
			case "L": direction = .west
			default: preconditionFailure()
			}

			let rawColorCode = String(components[2].dropFirst(2).dropLast(1))

			let part2Direction: Direction

			switch rawColorCode.last! {
			case "0": part2Direction = .east
			case "1": part2Direction = .south
			case "2": part2Direction = .west
			case "3": part2Direction = .north
			default: preconditionFailure()
			}

			return .init(
				direction: direction,
				steps: Int(components[1])!,
				part2Direction: part2Direction,
				part2Steps: Int(rawColorCode.dropLast(), radix: 16)!
			)
		})
	}
}
