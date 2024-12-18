import Foundation
import Tools

final class Day23Solver: DaySolver {
	let dayNumber: Int = 23

	struct Input {
		let instructions: [Instruction]
	}

	private enum Value {
		case constant(value: Int)
		case register(id: String)
	}

	enum Instruction {
		case half(registerID: String)
		case triple(registerID: String)
		case inc(registerID: String)
		case jump(offset: Int)
		case jumpOnEven(registerID: String, offset: Int)
		case jumpOnOne(registerID: String, offset: Int)
	}

	private struct CPU {
		let program: [Instruction]

		var a: Int = 0
		var b: Int = 0

		var ip: Int = 0

		var isCompleted: Bool {
			ip == program.count
		}

		mutating func executeNextInstruction() -> Bool {
			guard ip >= 0, ip < program.count else {
				return false
			}

			let instruction = program[ip]

			switch instruction {
			case .half(let registerID):
				switch registerID {
				case "a": a /= 2
				case "b": b /= 2
				default: fatalError()
				}
			case .triple(let registerID):
				switch registerID {
				case "a": a *= 3
				case "b": b *= 3
				default: fatalError()
				}
			case .inc(let registerID):
				switch registerID {
				case "a": a += 1
				case "b": b += 1
				default: fatalError()
				}
			case .jump(let offset):
				ip += offset - 1
			case .jumpOnEven(let registerID, let offset):
				let isEven: Bool

				switch registerID {
				case "a": isEven = (a % 2) == 0
				case "b": isEven = (b % 2) == 0
				default: fatalError()
				}

				if isEven {
					ip += offset - 1
				}
			case .jumpOnOne(let registerID, let offset):
				let doJump: Bool

				switch registerID {
				case "a": doJump = a == 1
				case "b": doJump = b == 1
				default: fatalError()
				}

				if doJump {
					ip += offset - 1
				}
			}

			ip += 1

			return true
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		var cpu = CPU(program: input.instructions)

		while cpu.executeNextInstruction() {}

		return cpu.b
	}

	func solvePart2(withInput input: Input) -> Int {
		var cpu = CPU(program: input.instructions)

		cpu.a = 1

		while cpu.executeNextInstruction() {}

		return cpu.b
	}

	func parseInput(rawString: String) -> Input {
		let instructions: [Instruction] = rawString.allLines().map { line in
			if let parameters = line.getCapturedValues(pattern: #"hlf ([a-b])"#) {
				.half(registerID: parameters[0])
			} else if let parameters = line.getCapturedValues(pattern: #"tpl ([a-b])"#) {
				.triple(registerID: parameters[0])
			} else if let parameters = line.getCapturedValues(pattern: #"inc ([a-b])"#) {
				.inc(registerID: parameters[0])
			} else if let parameters = line.getCapturedValues(pattern: #"jmp ([-+][0-9]*)"#) {
				.jump(offset: Int(parameters[0])!)
			} else if let parameters = line.getCapturedValues(pattern: #"jie ([a-b]), ([-+][0-9]*)"#) {
				.jumpOnEven(registerID: parameters[0], offset: Int(parameters[1])!)
			} else if let parameters = line.getCapturedValues(pattern: #"jio ([a-b]), ([-+][0-9]*)"#) {
				.jumpOnOne(registerID: parameters[0], offset: Int(parameters[1])!)
			} else {
				fatalError()
			}
		}

		return .init(instructions: instructions)
	}
}
