import Foundation
import Tools

final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	struct Input {
		let a: Int
		let b: Int
		let c: Int
		let program: [Operation]
		let rawInstructions: [Int]
	}

	enum Instruction: Int, RawRepresentable {
		case adv = 0
		case bxl
		case bst
		case jnz
		case bxc
		case out
		case bdv
		case cdv
	}

	struct Operation {
		let instruction: Instruction
		let operand: Int
	}

	struct CPU: CustomStringConvertible {
		var a: Int
		var b: Int
		var c: Int

		let program: [Operation]

		var ip: Int = 0

		var output: [Int] = []

		init(a: Int, b: Int, c: Int, program: [Operation]) {
			self.a = a
			self.b = b
			self.c = c
			self.program = program
		}

		var description: String {
			let output = output.map(String.init).joined(separator: ",")

			return """
				Register A: \(a)
				Register B: \(b)
				Register C: \(c)

				Output: \(output)
			"""
		}

		mutating func runTillHalt() -> [Int] {
			while runCycle() {}

			return output
		}

		mutating func runCycle() -> Bool {
			guard let operation = program[safe: ip] else {
				return false
			}

			var operand = operation.operand

			func parseComboOperand(_ operand: Int) -> Int {
				switch operand {
				case 0,
				     1,
				     2,
				     3: operation.operand
				case 4: a
				case 5: b
				case 6: c
				default: preconditionFailure()
				}
			}

			var newIp = ip

			switch operation.instruction {
			case .adv:
				operand = parseComboOperand(operand)

				let numerator = a
				let denominator = 2 << (operand - 1)

				a = numerator / denominator

			case .bxl:
				b = b ^ operand

			case .bst:
				b = parseComboOperand(operand) % 8

			case .jnz:
				if a != 0 {
					newIp = operand / 2
				}

			case .bxc:
				b = b ^ c

			case .out:
				output.append(parseComboOperand(operand) % 8)

			case .bdv:
				operand = parseComboOperand(operand)

				let numerator = a
				let denominator = 2 << (operand - 1)

				b = numerator / denominator

			case .cdv:
				operand = parseComboOperand(operand)

				let numerator = a
				let denominator = 2 << (operand - 1)

				c = numerator / denominator
			}

			if newIp != ip {
				ip = newIp
			} else {
				ip += 1
			}

			return true
		}
	}

	func findAForOutput(for a: Int, currentDigitID: Int, program: [Operation], expectedOutput: [Int]) -> Int? {
		var results: [Int] = []

		for newA in a ..< a + 8 {
			var cpu = CPU(a: newA, b: 0, c: 0, program: program)

			let output = cpu.runTillHalt()

			// We run from right to left
			if Array(expectedOutput[(expectedOutput.count - currentDigitID - 1)...]) == output {
				if currentDigitID == 15 {
					results.append(newA)
				} else if let result = findAForOutput(for: newA << 3, currentDigitID: currentDigitID + 1, program: program, expectedOutput: expectedOutput) {
					results.append(result)
				}
			}
		}

		return results.min()
	}

	func solvePart1(withInput input: Input) -> String {
		var cpu = CPU(a: input.a, b: input.b, c: input.c, program: input.program)

		let output = cpu.runTillHalt()

		return output.map(String.init).joined(separator: ",")
	}

	func solvePart2(withInput input: Input) -> Int {
		// Notes:
		//  * noticed that each power of 8 in A a new digit appears
		//  * looked at the patters and detected:
		//   -> register A influences the output in REVERSE
		//   -> thus the least significant values of A influence the end of the program output
		//   -> its a 3 bit system so only 8 values need to be tested for each output digit
		//
		// Reverse engineered program:
		//  while a != 0 {
		//   b = a % 8
		//   b = b ^ 3
		//   c = a >> b
		//   b = b ^ 5
		//   a = a >> 3
		//   b = b ^ c
		//	 output.append(b % 8)
		//  }

		findAForOutput(for: 0, currentDigitID: 0, program: input.program, expectedOutput: input.rawInstructions) ?? 0
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines()

		let rawProgramInts = lines[3].components(separatedBy: ": ")[1].parseCommaSeparatedInts()
		var program: [Operation] = []

		for index in stride(from: 0, to: rawProgramInts.count, by: 2) {
			let instruction = Instruction(rawValue: rawProgramInts[index])!
			let operand = rawProgramInts[index + 1]

			program.append(Operation(instruction: instruction, operand: operand))
		}

		return .init(
			a: Int(lines[0].components(separatedBy: ": ")[1])!,
			b: Int(lines[1].components(separatedBy: ": ")[1])!,
			c: Int(lines[2].components(separatedBy: ": ")[1])!,
			program: program,
			rawInstructions: rawProgramInts
		)
	}
}
