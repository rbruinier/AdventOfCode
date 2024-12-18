import Foundation
import Tools

final class Day25Solver: DaySolver {
	let dayNumber: Int = 25

	struct Input {
		let instructions: [Instruction]
	}

	enum Instruction {
		case cpy(value: Value, targetRegisterID: String)
		case inc(registerID: String)
		case dec(registerID: String)
		case jnz(value: Value, steps: Value)
		case out(value: Value)
	}

	enum Value {
		case value(value: Int)
		case register(id: String)
	}

	private struct CPU {
		var instructions: [Instruction]

		var registers: [String: Int] = [:]
		var ip = 0

		var isFinished: Bool {
			ip >= instructions.count
		}

		mutating func executeTillOutInstruction() -> Int {
			while true {
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
				case .out(let value):
					ip += 1

					switch value {
					case .value(let literalValue):
						return literalValue
					case .register(let sourceRegisterID):
						return registers[sourceRegisterID, default: 0]
					}
				}

				ip += 1
			}
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		// brute force works fine
		for startValue in 0 ..< 10000 {
			var cpu = CPU(instructions: input.instructions)

			cpu.registers["a"] = startValue

			var counter = 0
			while true {
				let output = cpu.executeTillOutInstruction()

				if output != counter % 2 {
					break
				}

				counter += 1

				if counter == 10 {
					return startValue
				}
			}
		}

		return 0
	}

	func solvePart2(withInput input: Input) -> String {
		"Merry Christmas 🎄"
	}

	func parseInput(rawString: String) -> Input {
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
			case "out":
				let value1: Value

				if let value = Int(components[1]) {
					value1 = .value(value: value)
				} else {
					value1 = .register(id: components[1])
				}

				return .out(value: value1)
			default: fatalError()
			}
		}

		return .init(instructions: instructions)
	}
}
