import Foundation
import Tools

final class Day19Solver: DaySolver {
	let dayNumber: Int = 19

	private var input: Input!

	private struct Input {
		let program: [Instruction]
		let ip: Int
	}

	private struct Instruction {
		let operation: Operation
		let operands: [Int]
	}

	private enum Operation: String, RawRepresentable {
		case addr
		case addi
		case mulr
		case muli
		case banr
		case bani
		case borr
		case bori
		case setr
		case seti
		case gtir
		case gtri
		case gtrr
		case eqir
		case eqri
		case eqrr

		func executeOn(registers: inout [Int], operands: [Int]) {
			let srcAIndex = operands[0]
			let srcBIndex = operands[1]
			let destIndex = operands[2]

			let aValue = operands[0]
			let bValue = operands[1]

			switch self {
			case .addr: registers[destIndex] = registers[srcAIndex] + registers[srcBIndex]
			case .addi: registers[destIndex] = registers[srcAIndex] + bValue
			case .mulr: registers[destIndex] = registers[srcAIndex] * registers[srcBIndex]
			case .muli: registers[destIndex] = registers[srcAIndex] * bValue
			case .banr: registers[destIndex] = registers[srcAIndex] & registers[srcBIndex]
			case .bani: registers[destIndex] = registers[srcAIndex] & bValue
			case .borr: registers[destIndex] = registers[srcAIndex] | registers[srcBIndex]
			case .bori: registers[destIndex] = registers[srcAIndex] | bValue
			case .setr: registers[destIndex] = registers[srcAIndex]
			case .seti: registers[destIndex] = aValue
			case .gtir: registers[destIndex] = aValue > registers[srcBIndex] ? 1 : 0
			case .gtri: registers[destIndex] = registers[srcAIndex] > bValue ? 1 : 0
			case .gtrr: registers[destIndex] = registers[srcAIndex] > registers[srcBIndex] ? 1 : 0
			case .eqir: registers[destIndex] = aValue == registers[srcBIndex] ? 1 : 0
			case .eqri: registers[destIndex] = registers[srcAIndex] == bValue ? 1 : 0
			case .eqrr: registers[destIndex] = registers[srcAIndex] == registers[srcBIndex] ? 1 : 0
			}
		}
	}

	func solvePart1() -> Int {
		var registers: [Int] = .init(repeating: 0, count: 6)

		let ipRegister = input.ip
		var ipValue = 0

		while true {
			guard let instruction = input.program[safe: ipValue] else {
				break
			}

			registers[ipRegister] = ipValue

			instruction.operation.executeOn(registers: &registers, operands: instruction.operands)

			ipValue = registers[ipRegister] + 1
		}

		return registers[0]
	}

	// By looking at what section of the program was repeating the most I reverse engineered the instructions of that section and rewrote it in a function.
	//
	// It adds the input (r4) to r0 if it r3 can be divided by r4.
	//
	// Section:
	// 02: seti 1 5 5 -> R5 = 1                 -> IP + 1
	// 03: mulr 4 5 1 -> R1 = R4 * R5           -> IP + 1
	// 04: eqrr 1 3 1 -> R1 = R1 == R3 ? 1 : 0  -> IP + 1
	// 05: addr 1 2 2 -> R2 = R1 + R2           -> IP + 1 OR + 2 IF R1 == R3
	// 06: addi 2 1 2 -> R2 = R2 + 1            -> IP + 2 // we skip 7 if R != R3
	// 07: addr 4 0 0 -> R0 = R4 + R0           -> IP + 1
	// 08: addi 5 1 5 -> R5 = R5 + 1            -> IP + 1
	// 09: gtrr 5 3 1 -> R1 = R5 > R3 ? 1 : 0   -> IP + 1
	// 10: addr 2 1 2 -> R2 = R2 + R1           -> IP + 1 OR + 2 IF R5 > R3
	// 11: seti 2 6 2 -> R2 = 2
	//
	// In pseudocode:
	// repeat {
	//  let r1 = r4 * r5
	//  if r1 == r3 {
	//   r0 += r4
	//  }
	//  r5 += 1
	// } while r5 <= r3
	@inline(__always)
	private func performDivisorSection(_ registers: inout [Int]) {
		registers[0] += (registers[3] % registers[4]) == 0 ? registers[4] : 0
		registers[2] = 11
	}

	func solvePart2() -> Int {
		var registers: [Int] = .init(repeating: 0, count: 6)

		let ipRegister = input.ip
		var ipValue = 0

		registers[0] = 1

		while true {
			guard let instruction = input.program[safe: ipValue] else {
				break
			}

			registers[ipRegister] = ipValue

			if ipValue == 2 {
				performDivisorSection(&registers)
			} else {
				instruction.operation.executeOn(registers: &registers, operands: instruction.operands)
			}

			ipValue = registers[ipRegister] + 1
		}

		return registers[0]
	}

	func parseInput(rawString: String) {
		var program: [Instruction] = []
		var ip: Int = -1

		for line in rawString.allLines() {
			if let parameters = line.getCapturedValues(pattern: #"([a-z]*) ([0-9]*) ([0-9]*) ([0-9]*)"#) {
				program.append(.init(
					operation: Operation(rawValue: parameters[0])!,
					operands: parameters[1 ... 3].map { Int($0)! }
				))
			} else if let parameters = line.getCapturedValues(pattern: #"#ip ([0-9]*)"#) {
				ip = Int(parameters[0])!
			}
		}

		assert(ip != -1)

		input = .init(program: program, ip: ip)
	}
}
