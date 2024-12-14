import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	struct Input {
		let lines: [[Step]]
	}

	private enum Step: String {
		case up = "U"
		case right = "R"
		case down = "D"
		case left = "L"
	}

	func solvePart1(withInput input: Input) -> String {
		let digits: [Point2D: Int] = [
			.init(x: -1, y: -1): 1,
			.init(x: 0, y: -1): 2,
			.init(x: 1, y: -1): 3,
			.init(x: -1, y: 0): 4,
			.init(x: 0, y: 0): 5,
			.init(x: 1, y: 0): 6,
			.init(x: -1, y: 1): 7,
			.init(x: 0, y: 1): 8,
			.init(x: 1, y: 1): 9,
		]

		var code = ""

		var position = Point2D() // 5
		for line in input.lines {
			for step in line {
				let newPosition: Point2D

				switch step {
				case .up: newPosition = position.moved(to: .north)
				case .right: newPosition = position.moved(to: .east)
				case .down: newPosition = position.moved(to: .south)
				case .left: newPosition = position.moved(to: .west)
				}

				if digits.keys.contains(newPosition) {
					position = newPosition
				}
			}

			code += String(digits[position]!)
		}

		return code
	}

	func solvePart2(withInput input: Input) -> String {
		let digits: [Point2D: String] = [
			.init(x: 0, y: -2): "1",
			.init(x: -1, y: -1): "2",
			.init(x: 0, y: -1): "3",
			.init(x: 1, y: -1): "4",
			.init(x: -2, y: 0): "5",
			.init(x: -1, y: 0): "6",
			.init(x: 0, y: 0): "7",
			.init(x: 1, y: 0): "8",
			.init(x: 2, y: 0): "9",
			.init(x: -1, y: 1): "A",
			.init(x: 0, y: 1): "B",
			.init(x: 1, y: 1): "C",
			.init(x: 0, y: 2): "D",
		]

		var code = ""

		var position = Point2D(x: -2, y: 0) // 5
		for line in input.lines {
			for step in line {
				let newPosition: Point2D

				switch step {
				case .up: newPosition = position.moved(to: .north)
				case .right: newPosition = position.moved(to: .east)
				case .down: newPosition = position.moved(to: .south)
				case .left: newPosition = position.moved(to: .west)
				}

				if digits.keys.contains(newPosition) {
					position = newPosition
				}
			}

			code += String(digits[position]!)
		}

		return code
	}

	func parseInput(rawString: String) -> Input {
		let lines: [[Step]] = rawString.allLines().map { line in
			line.map { Step(rawValue: String($0))! }
		}

		return .init(lines: lines)
	}
}
