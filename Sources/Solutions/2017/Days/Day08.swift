import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	struct Input {
		let instructions: [Instruction]
	}

	private enum Instruction {
		case inc(register: String, amount: Int, conditionRegister: String, conditionConstant: Int, conditional: (_ a: Int, _ b: Int) -> Bool)
		case dec(register: String, amount: Int, conditionRegister: String, conditionConstant: Int, conditional: (_ a: Int, _ b: Int) -> Bool)
	}

	func solvePart1(withInput input: Input) -> Int {
		var registers: [String: Int] = [:]

		for instruction in input.instructions {
			switch instruction {
			case .inc(let register, let amount, let conditionRegister, let conditionConstant, let conditional):
				registers[register, default: 0] += conditional(registers[conditionRegister, default: 0], conditionConstant) ? amount : 0
			case .dec(let register, let amount, let conditionRegister, let conditionConstant, let conditional):
				registers[register, default: 0] -= conditional(registers[conditionRegister, default: 0], conditionConstant) ? amount : 0
			}
		}

		return registers.values.max()!
	}

	func solvePart2(withInput input: Input) -> Int {
		var highestValue = Int.min

		var registers: [String: Int] = [:]

		for instruction in input.instructions {
			switch instruction {
			case .inc(let register, let amount, let conditionRegister, let conditionConstant, let conditional):
				registers[register, default: 0] += conditional(registers[conditionRegister, default: 0], conditionConstant) ? amount : 0
				highestValue = max(highestValue, registers[register]!)
			case .dec(let register, let amount, let conditionRegister, let conditionConstant, let conditional):
				registers[register, default: 0] -= conditional(registers[conditionRegister, default: 0], conditionConstant) ? amount : 0
				highestValue = max(highestValue, registers[register]!)
			}
		}

		return highestValue
	}

	func parseInput(rawString: String) -> Input {
		let instructions: [Instruction] = rawString.allLines().map { line in
			let components = line.components(separatedBy: " ")

			let register = components[0]
			let op = components[1]
			let amount = Int(components[2])!
			let a = components[4]
			let b = Int(components[6])!

			let conditional: (Int, Int) -> Bool

			switch components[5] {
			case "<": conditional = (<)
			case ">": conditional = (>)
			case "<=": conditional = (<=)
			case ">=": conditional = (>=)
			case "==": conditional = (==)
			case "!=": conditional = (!=)
			default: fatalError()
			}

			switch op {
			case "inc":
				return .inc(register: register, amount: amount, conditionRegister: a, conditionConstant: b, conditional: conditional)
			case "dec":
				return .dec(register: register, amount: amount, conditionRegister: a, conditionConstant: b, conditional: conditional)
			default:
				fatalError()
			}
		}

		return .init(instructions: instructions)
	}
}
