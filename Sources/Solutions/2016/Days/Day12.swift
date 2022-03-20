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
		case cpy(value: Value, targetRegisterId: String)
		case inc(registerId: String)
		case dec(registerId: String)
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
			case .cpy(let value, let targetRegisterId):
				switch value {
				case .value(let literalValue):
					registers[targetRegisterId] = literalValue
				case .register(let sourceRegisterId):
					registers[targetRegisterId] = registers[sourceRegisterId, default: 0]
				}
			case .inc(let registerId):
				registers[registerId, default: 0] += 1
			case .dec(let registerId):
				registers[registerId, default: 0] -= 1
			case .jnz(let value, let steps):
				var testValue: Int
				switch value {
				case .value(let literalValue):
					testValue = literalValue
				case .register(let sourceRegisterId):
					testValue = registers[sourceRegisterId, default: 0]
				}

				if testValue != 0 {
					ip += steps - 1
				}
			}
			
			ip += 1
		}
	}

	func solvePart1() -> Any {
		var cpu = CPU(instructions: input.instructions)
		
		while cpu.isFinished == false {
			cpu.executeNextInstruction()
		}
		
		return cpu.registers["a"]!
	}

	func solvePart2() -> Any {
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
					return .cpy(value: .value(value: value), targetRegisterId: components[2])
				} else {
					return .cpy(value: .register(id: components[1]), targetRegisterId: components[2])
				}
			case "inc":
				return .inc(registerId: components[1])
			case "dec":
				return .dec(registerId: components[1])
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
