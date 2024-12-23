import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	struct Input {
		var program: [Instruction]
	}

	enum Instruction {
		case accumulator(value: Int)
		case jump(offset: Int)
		case noOperation(value: Int)
	}

	private struct CPU {
		let program: [Instruction]

		var executedIps: [Int] = []

		var accumulator: Int = 0
		var ip: Int = 0

		var isCompleted: Bool {
			ip == program.count
		}

		mutating func executeNextInstruction() -> Bool {
			guard ip >= 0, ip < program.count, executedIps.contains(ip) == false else {
				return false
			}

			executedIps.append(ip)

			let instruction = program[ip]

			switch instruction {
			case .accumulator(let value):
				accumulator += value
			case .jump(let offset):
				ip += offset - 1
			case .noOperation:
				break
			}

			ip += 1

			return true
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		var cpu = CPU(program: input.program)

		while cpu.executeNextInstruction() {}

		return cpu.accumulator
	}

	func solvePart2(withInput input: Input) -> Int {
		for ip in 0 ..< input.program.count {
			var program = input.program

			switch program[ip] {
			case .accumulator:
				continue
			case .jump(let offset):
				program[ip] = .noOperation(value: offset)
			case .noOperation(let value):
				program[ip] = .jump(offset: value)
			}

			var cpu = CPU(program: program)

			while cpu.executeNextInstruction() {}

			if cpu.isCompleted {
				return cpu.accumulator
			}
		}

		return 0
	}

	func parseInput(rawString: String) -> Input {
		let instructions: [Instruction] = rawString.allLines().compactMap {
			let parts = $0.components(separatedBy: .whitespaces)

			guard let value = Int(parts[1]) else {
				fatalError()
			}

			switch parts[0] {
			case "acc": return .accumulator(value: value)
			case "jmp": return .jump(offset: value)
			case "nop": return .noOperation(value: value)
			default: fatalError()
			}
		}

		return .init(program: instructions)
	}
}
