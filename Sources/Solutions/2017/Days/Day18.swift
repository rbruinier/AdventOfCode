import Foundation
import Tools

final class Day18Solver: DaySolver {
	let dayNumber: Int = 18

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
		case snd(a: Operand)
		case set(a: Operand, b: Operand)
		case add(a: Operand, b: Operand)
		case mul(a: Operand, b: Operand)
		case mod(a: Operand, b: Operand)
		case rcv(a: Operand)
		case jgz(a: Operand, b: Operand)
	}

	private struct CPUPart1 {
		let instructions: [Instruction]

		var registers: [String: Int] = [:]
		var ip: Int = 0

		var lastFrequency = 0
		var receivedFrequency = 0

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

			switch instruction {
			case .set(let a, let b):
				registers[a.registerID!] = getValue(of: b)
			case .add(let a, let b):
				registers[a.registerID!] = getValue(of: a) + getValue(of: b)
			case .mul(let a, let b):
				registers[a.registerID!] = getValue(of: a) * getValue(of: b)
			case .mod(let a, let b):
				registers[a.registerID!] = getValue(of: a) % getValue(of: b)
			case .jgz(let a, let b):
				ip += getValue(of: a) > 0 ? (getValue(of: b) - 1) : 0
			case .snd(let a):
				lastFrequency = getValue(of: a)
			case .rcv(let a):
				receivedFrequency = getValue(of: a) != 0 ? lastFrequency : receivedFrequency
			}

			ip += 1

			return false
		}
	}

	private struct CPUPart2 {
		let instructions: [Instruction]

		var registers: [String: Int] = [:]
		var ip: Int = 0

		var inputQueue: [Int] = []

		var sendCount = 0

		private func getValue(of operand: Operand) -> Int {
			switch operand {
			case .value(let value):
				value
			case .register(let id):
				registers[id, default: 0]
			}
		}

		enum State {
			case ok
			case waitingForInput
			case output(value: Int)
			case endOfProgram
		}

		mutating func executeNextInstruction() -> State {
			guard let instruction = instructions[safe: ip] else {
				return .endOfProgram
			}

			switch instruction {
			case .set(let a, let b):
				registers[a.registerID!] = getValue(of: b)
			case .add(let a, let b):
				registers[a.registerID!] = getValue(of: a) + getValue(of: b)
			case .mul(let a, let b):
				registers[a.registerID!] = getValue(of: a) * getValue(of: b)
			case .mod(let a, let b):
				registers[a.registerID!] = getValue(of: a) % getValue(of: b)
			case .jgz(let a, let b):
				ip += getValue(of: a) > 0 ? (getValue(of: b) - 1) : 0
			case .snd(let a):
				ip += 1
				sendCount += 1

				return .output(value: getValue(of: a))
			case .rcv(let a):
				if inputQueue.isNotEmpty {
					registers[a.registerID!] = inputQueue.removeFirst()
				} else {
					// keep the IP at same spot so we just keep on waiting
					return .waitingForInput
				}
			}

			ip += 1

			return .ok
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		var cpu = CPUPart1(instructions: input.instructions)

		while cpu.executeNextInstruction() == false {
			if cpu.receivedFrequency != 0 {
				return cpu.receivedFrequency
			}
		}

		fatalError()
	}

	func solvePart2(withInput input: Input) -> Int {
		var cpu1 = CPUPart2(instructions: input.instructions)
		var cpu2 = CPUPart2(instructions: input.instructions)

		cpu1.registers["p"] = 0
		cpu2.registers["p"] = 1

		executionLoop: while true {
			var waitingCount = 0

			switch cpu1.executeNextInstruction() {
			case .ok:
				break
			case .output(let value):
				cpu2.inputQueue.append(value)
			case .waitingForInput:
				waitingCount += 1
			case .endOfProgram:
				break executionLoop
			}

			switch cpu2.executeNextInstruction() {
			case .ok:
				break
			case .output(let value):
				cpu1.inputQueue.append(value)
			case .waitingForInput:
				waitingCount += 1
			case .endOfProgram:
				break executionLoop
			}

			if waitingCount == 2 {
				break
			}
		}

		return cpu2.sendCount
	}

	func parseInput(rawString: String) -> Input {
		func parseOperand(_ text: String) -> Operand {
			if let value = Int(text) {
				.value(value)
			} else {
				.register(id: text)
			}
		}

		return .init(instructions: rawString.allLines().map { part in
			if let values = part.getCapturedValues(pattern: #"set ([a-z]*) (-?[0-9a-z]*)"#) {
				.set(a: parseOperand(values[0]), b: parseOperand(values[1]))
			} else if let values = part.getCapturedValues(pattern: #"add ([a-z]*) (-?[0-9a-z]*)"#) {
				.add(a: parseOperand(values[0]), b: parseOperand(values[1]))
			} else if let values = part.getCapturedValues(pattern: #"mul ([a-z]*) (-?[0-9a-z]*)"#) {
				.mul(a: parseOperand(values[0]), b: parseOperand(values[1]))
			} else if let values = part.getCapturedValues(pattern: #"mod ([a-z]*) (-?[0-9a-z]*)"#) {
				.mod(a: parseOperand(values[0]), b: parseOperand(values[1]))
			} else if let values = part.getCapturedValues(pattern: #"jgz (-?[0-9a-z]*) (-?[0-9a-z]*)"#) {
				.jgz(a: parseOperand(values[0]), b: parseOperand(values[1]))
			} else if let values = part.getCapturedValues(pattern: #"rcv ([a-z]*)"#) {
				.rcv(a: parseOperand(values[0]))
			} else if let values = part.getCapturedValues(pattern: #"snd ([a-z]*)"#) {
				.snd(a: parseOperand(values[0]))
			} else {
				fatalError()
			}
		})
	}
}
