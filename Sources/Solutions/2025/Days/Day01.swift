import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	private var input: Input!

	enum Direction: String {
		case left = "L"
		case right = "R"
	}

	struct Instruction {
		let direction: Direction
		let quantity: Int
	}

	struct Input {
		let instructions: [Instruction]
	}

	func solvePart1(withInput input: Input) -> Int {
		var position = 50

		var nrOfZeros = 0

		for instruction in input.instructions {
			switch instruction.direction {
			case .left: position -= instruction.quantity
			case .right: position += instruction.quantity
			}

			position = mod(position, 100)

			if position == 0 {
				nrOfZeros += 1
			}
		}

		return nrOfZeros
	}

	func solvePart2(withInput input: Input) -> Int {
		var position = 50

		var nrOfZeros = 0

		for instruction in input.instructions {
			for _ in 0 ..< instruction.quantity {
				switch instruction.direction {
				case .left: position -= 1
				case .right: position += 1
				}

				if position % 100 == 0 {
					nrOfZeros += 1
				}
			}
		}

		return nrOfZeros
	}

	func parseInput(rawString: String) -> Input {
		let instructions: [Instruction] = rawString.allLines().map { line in
			let direction = Direction(rawValue: String(line[0]))!
			let quantity = Int(String(line[1 ..< line.count]))!

			return Instruction(direction: direction, quantity: quantity)
		}

		return Input(instructions: instructions)
	}
}
