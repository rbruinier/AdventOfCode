import Foundation
import Tools

final class Day12Solver: DaySolver {
	let dayNumber: Int = 12

	private var input: Input!

	private struct Input {
		let instructions: [Instruction]
	}

	private enum Value {
		case value(value: Int)
		case register(id: String)
	}

	private enum Instruction {
		case cpy(value: Value, targetRegisterID: String)
		case inc(registerID: String)
		case dec(registerID: String)
		case jnz(value: Value, steps: Int)
	}

	private struct CPU {
		let instructions: [Instruction]

		var registers: [String: Int] = [:]
		var ip = 0

		var isFinished: Bool {
			ip >= instructions.count
		}

		mutating func executeNextInstruction() {
			switch instructions[ip] {
			case .cpy(let value, let targetRegisterID):
				switch value {
				case .value(let literalValue):
					registers[targetRegisterID] = literalValue
				case .register(let sourceRegisterID):
					registers[targetRegisterID] = registers[sourceRegisterID, default: 0]
				}
			case .inc(let registerID):
				registers[registerID, default: 0] += 1
			case .dec(let registerID):
				registers[registerID, default: 0] -= 1
			case .jnz(let value, let steps):
				var testValue: Int
				switch value {
				case .value(let literalValue):
					testValue = literalValue
				case .register(let sourceRegisterID):
					testValue = registers[sourceRegisterID, default: 0]
				}

				if testValue != 0 {
					ip += steps - 1
				}
			}

			ip += 1
		}
	}

	func solvePart1() -> Int {
		var cpu = CPU(instructions: input.instructions)

		while cpu.isFinished == false {
			cpu.executeNextInstruction()
		}

		return cpu.registers["a"]!
	}

	func solvePart2() -> Int {
		var cpu = CPU(instructions: input.instructions)

		cpu.registers["c"] = 1

		while cpu.isFinished == false {
			cpu.executeNextInstruction()
		}

		return cpu.registers["a"]!
	}

	func parseInput(rawString: String) {
		let instructions: [Instruction] = rawString.allLines().map { line in
			let components = line.components(separatedBy: " ")

			switch components[0] {
			case "cpy":
				if let value = Int(components[1]) {
					return .cpy(value: .value(value: value), targetRegisterID: components[2])
				} else {
					return .cpy(value: .register(id: components[1]), targetRegisterID: components[2])
				}
			case "inc":
				return .inc(registerID: components[1])
			case "dec":
				return .dec(registerID: components[1])
			case "jnz":
				if let value = Int(components[1]) {
					return .jnz(value: .value(value: value), steps: Int(components[2])!)
				} else {
					return .jnz(value: .register(id: components[1]), steps: Int(components[2])!)
				}
			default: fatalError()
			}
		}

		input = .init(instructions: instructions)
	}
}
