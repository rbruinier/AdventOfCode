import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	struct Input {
		let instructions: [Instruction]

		let width = 50
		let height = 6
	}

	enum Instruction {
		case rect(width: Int, height: Int)
		case rotateRow(y: Int, by: Int)
		case rotateColumn(x: Int, by: Int)
	}

	private var solvedGrid: [Bool]!

	func solvePart1(withInput input: Input) -> Int {
		let width = input.width
		let height = input.height

		var grid: [Bool] = Array(repeating: false, count: width * height)

		for instruction in input.instructions {
			var newGrid = grid

			switch instruction {
			case .rect(let rectWidth, let rectHeight):
				for y in 0 ..< rectHeight {
					for x in 0 ..< rectWidth {
						newGrid[y * width + x] = true
					}
				}
			case .rotateRow(let y, let count):
				for x in 0 ..< width {
					newGrid[y * width + (x + count) % width] = grid[y * width + x]
				}
			case .rotateColumn(let x, let count):
				for y in 0 ..< height {
					newGrid[((y + count) % height) * width + x] = grid[y * width + x]
				}
			}

			grid = newGrid
		}

		solvedGrid = grid

		return grid.filter { $0 }.count
	}

	func solvePart2(withInput input: Input) -> String {
		var index = 0
		for _ in 0 ..< input.height {
			var result = ""

			for _ in 0 ..< input.width {
				result += solvedGrid[index] ? " # " : "   "

				index += 1
			}

			//            print(result)
		}

		// taken from printed output

		return "UPOJFLBCEZ"
	}

	func parseInput(rawString: String) -> Input {
		let instructions: [Instruction] = rawString.allLines().map { line in
			if let values = line.getCapturedValues(pattern: #"rect ([0-9]*)x([0-9]*)"#) {
				.rect(width: Int(values[0])!, height: Int(values[1])!)
			} else if let values = line.getCapturedValues(pattern: #"rotate row y=([0-9]*) by ([0-9]*)"#) {
				.rotateRow(y: Int(values[0])!, by: Int(values[1])!)
			} else if let values = line.getCapturedValues(pattern: #"rotate column x=([0-9]*) by ([0-9]*)"#) {
				.rotateColumn(x: Int(values[0])!, by: Int(values[1])!)
			} else {
				fatalError()
			}
		}

		return .init(instructions: instructions)
	}
}
