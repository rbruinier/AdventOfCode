import Foundation
import Tools

// heatmap highlights instructions 11 to 19

// 11 set g d
// 12 mul g e
// 13 sub g b
// 14 jnz g 2
// 15 set f 0
// 16 sub e -1
// 17 set g e
// 18 sub g b
// 19 jnz g -8

/// First tried to solve part 2 by creating a heatmap of instructions to see if something could be easily replaced but found that difficult so instead
/// copied the program in swift to understand what was going on. It loops from value b to c in incremental steps of 17. This value is checked to be a prime
/// number. All non prime numbers are counted in h.
final class Day23Solver: DaySolver {
	let dayNumber: Int = 23

	struct Input {
		let instructions: [Instruction]
	}

	enum Operand {
		case value(Int)
		case register(id: String)

		var registerID: String? {
			switch self {
			case .value:
				nil
			case .register(let id):
				id
			}
		}
	}

	enum Instruction {
		case set(a: Operand, b: Operand)
		case sub(a: Operand, b: Operand)
		case mul(a: Operand, b: Operand)
		case jnz(a: Operand, b: Operand)
	}

	private struct CPU {
		let instructions: [Instruction]

		var registers: [String: Int] = [:]
		var ip: Int = 0

		var mulInstructionCounter = 0

		var instructionHeatMap: [Int: Int] = [:]

		private func getValue(of operand: Operand) -> Int {
			switch operand {
			case .value(let value):
				value
			case .register(let id):
				registers[id, default: 0]
			}
		}

		mutating func executeNextInstruction() -> Bool {
			guard let instruction = instructions[safe: ip] else {
				return true
			}

			instructionHeatMap[ip, default: 0] += 1

			switch instruction {
			case .set(let a, let b):
				registers[a.registerID!] = getValue(of: b)
			case .sub(let a, let b):
				registers[a.registerID!] = getValue(of: a) - getValue(of: b)
			case .mul(let a, let b):
				registers[a.registerID!] = getValue(of: a) * getValue(of: b)

				mulInstructionCounter += 1
			case .jnz(let a, let b):
				ip += getValue(of: a) != 0 ? (getValue(of: b) - 1) : 0
			}

			ip += 1

			return false
		}
	}

	private func actualProgram() -> Int {
		var b = 0
		var c = 0
		var h = 0

		b = 57 // 00 set b 57
		c = b // 01 set c b

		b = b * 100 // 04 mul b 100
		b = b + 100_000 // 05 sub b -100000

		c = b // 06 set c b

		c = c + 17_000 // 07 sub c -17000

		for number in stride(from: b, through: c, by: 17) {
			if number.isPrime == false {
				h += 1
			}
		}

		return h
	}

	func solvePart1(withInput input: Input) -> Int {
		var cpu = CPU(instructions: input.instructions)

		while cpu.executeNextInstruction() == false {}

		return cpu.mulInstructionCounter
	}

	func solvePart2(withInput input: Input) -> Int {
		actualProgram()
	}

	func parseInput(rawString: String) -> Input {
		.init(instructions: rawString.allLines().map { line in
			let components = line.components(separatedBy: " ")

			let operandA: Operand
			let operandB: Operand

			if let valueA = Int(components[1]) {
				operandA = .value(valueA)
			} else {
				operandA = .register(id: components[1])
			}

			if let valueB = Int(components[2]) {
				operandB = .value(valueB)
			} else {
				operandB = .register(id: components[2])
			}

			switch components[0] {
			case "set": return .set(a: operandA, b: operandB)
			case "sub": return .sub(a: operandA, b: operandB)
			case "mul": return .mul(a: operandA, b: operandB)
			case "jnz": return .jnz(a: operandA, b: operandB)
			default: fatalError()
			}
		})
	}
}
