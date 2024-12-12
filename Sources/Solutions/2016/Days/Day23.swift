import Foundation
import Tools

final class Day23Solver: DaySolver {
	let dayNumber: Int = 23

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
		case jnz(value: Value, steps: Value)
		case tgl(registerID: String)

		// introduced by me
		case nop
		case mul(registerA: String, registerB: String, targetRegisterID: String)
	}

	private struct CPU {
		var instructions: [Instruction]

		var registers: [String: Int] = [:]
		var ip = 0

		var isFinished: Bool {
			ip >= instructions.count
		}

		var hits: [Int: Int] = [:]

		mutating func executeNextInstruction() {
			//			hits[ip] = hits[ip, default: 0] + 1

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
				var stepsValue: Int

				switch value {
				case .value(let literalValue):
					testValue = literalValue
				case .register(let sourceRegisterID):
					testValue = registers[sourceRegisterID, default: 0]
				}

				switch steps {
				case .value(let literalValue):
					stepsValue = literalValue
				case .register(let sourceRegisterID):
					stepsValue = registers[sourceRegisterID, default: 0]
				}

				if testValue != 0 {
					ip += stepsValue - 1
				}
			case .tgl(let sourceRegisterID):
				let modifyIP = ip + registers[sourceRegisterID, default: 0]

				if instructions.indices.contains(modifyIP) == false {
					break
				}

				switch instructions[modifyIP] {
				case .inc(let registerID):
					instructions[modifyIP] = .dec(registerID: registerID)
				case .dec(let registerID):
					instructions[modifyIP] = .inc(registerID: registerID)
				case .tgl(let sourceRegisterID):
					instructions[modifyIP] = .inc(registerID: sourceRegisterID)
				case .jnz(let value, let steps):
					switch steps {
					case .register(let registerID):
						instructions[modifyIP] = .cpy(value: value, targetRegisterID: registerID)
					case .value:
						instructions[modifyIP] = .nop
					}
				case .cpy(let value, let targetRegisterID):
					instructions[modifyIP] = .jnz(value: value, steps: .register(id: targetRegisterID))
				case .mul:
					instructions[modifyIP] = .nop
				case .nop:
					break
				}
			case .nop:
				break
			case .mul(let registerA, let registerB, let targetRegisterID):
				let valueA = registers[registerA, default: 0]
				let valueB = registers[registerB, default: 0]

				registers[targetRegisterID] = valueA * valueB
			}

			ip += 1
		}
	}

	func solvePart1() -> Int {
		var cpu = CPU(instructions: input.instructions)

		cpu.registers["a"] = 7

		while cpu.isFinished == false {
			cpu.executeNextInstruction()
		}

		return cpu.registers["a"]!
	}

	func solvePart2() -> Int {
		/*
		 This solution required me to reverse engineer some of the assembly code. First a counter per instruction was kept and
		 printed after letting it run for a few seconds. This gave insight in what instructions are the hotspots to focus on. This
		 turned out to be two nested loops (in instruction 5 through 9) incrementing a. This can be replaced with a multiplication
		 instruction resulting in a fast solution.

		 0: cpy a b  -> a = 12, b = 12
		 1: dec b    -> a = 12, b = 11
		 2: cpy a d  -> a = 12, b = 11, d = 12
		 3: cpy 0 a  -> a =  0, b = 11, d = 12
		 4: cpy b c  -> a =  0, b = 11, c = 11, d = 12

		 5: inc a    -> a =  1, b = 11, c = 11, d = 12
		 6: dec c    -> a =  1, b = 11, c = 10, d = 12
		 7: jnz c -2 -> a = 11, b = 11, c =  0, d = 12
		 8: dec d    -> a = 11, b = 11, c =  0, d = 11
		 9: jnz d -5 -> etc

		 Can be rewritten as 5: a = c * d & rest of 6 ... 9 -> nop
		 */

		var cpu = CPU(instructions: input.instructions)

		cpu.registers["a"] = 12

		cpu.instructions[5] = .mul(registerA: "c", registerB: "d", targetRegisterID: "a")
		cpu.instructions[6] = .nop
		cpu.instructions[7] = .nop
		cpu.instructions[8] = .nop
		cpu.instructions[9] = .nop

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
				let value1: Value
				let value2: Value

				if let value = Int(components[1]) {
					value1 = .value(value: value)
				} else {
					value1 = .register(id: components[1])
				}

				if let value = Int(components[2]) {
					value2 = .value(value: value)
				} else {
					value2 = .register(id: components[2])
				}

				return .jnz(value: value1, steps: value2)
			case "tgl":
				return .tgl(registerID: components[1])
			default: fatalError()
			}
		}

		input = .init(instructions: instructions)
	}
}
