import Foundation
import Tools

final class Day10Solver: DaySolver {
	let dayNumber: Int = 10

	struct Input {
		let instructions: [Instruction]
	}

	enum Output {
		case bot(index: Int)
		case output(index: Int)
	}

	enum Instruction {
		case value(botIndex: Int, value: Int)
		case give(botIndex: Int, low: Output, high: Output)
	}

	private struct Bot {
		var values: [Int] = []

		var low: Int {
			values.min()!
		}

		var high: Int {
			values.max()!
		}
	}

	private func solve(instructions originalInstructions: [Instruction]) -> (bots: [Int: Bot], outputs: [Int: Int]) {
		var bots: [Int: Bot] = [:]
		var outputs: [Int: Int] = [:]

		var instructions: [Instruction] = []

		for instruction in originalInstructions {
			switch instruction {
			case .value(let botIndex, let value):
				bots[botIndex, default: Bot()].values.append(value)
			default:
				instructions.append(instruction)
			}
		}

		while instructions.isNotEmpty {
			var newInstructions: [Instruction] = []

			for instruction in instructions {
				switch instruction {
				case .give(let botIndex, let lowOutput, let highOutput):
					if bots[botIndex, default: Bot()].values.count == 2 {
						switch lowOutput {
						case .bot(let index):
							bots[index, default: Bot()].values.append(bots[botIndex]!.low)
						case .output(let index):
							outputs[index] = bots[botIndex]!.low
						}

						switch highOutput {
						case .bot(let index):
							bots[index, default: Bot()].values.append(bots[botIndex]!.high)
						case .output(let index):
							outputs[index] = bots[botIndex]!.high
						}
					} else {
						newInstructions.append(instruction)
					}
				default:
					fatalError()
				}
			}

			instructions = newInstructions
		}

		return (bots: bots, outputs: outputs)
	}

	func solvePart1(withInput input: Input) -> Int {
		let (bots, _) = solve(instructions: input.instructions)

		return bots.first(where: { $0.value.low == 17 && $0.value.high == 61 })!.key
	}

	func solvePart2(withInput input: Input) -> Int {
		let (_, outputs) = solve(instructions: input.instructions)

		return outputs[0]! * outputs[1]! * outputs[2]!
	}

	func parseInput(rawString: String) -> Input {
		func parseOutput(from string: String) -> Output {
			let parts = string.components(separatedBy: " ")

			if parts[0] == "bot" {
				return .bot(index: Int(parts[1])!)
			} else if parts[0] == "output" {
				return .output(index: Int(parts[1])!)
			} else {
				fatalError()
			}
		}

		let instructions: [Instruction] = rawString.allLines().map { line in
			if let values = line.getCapturedValues(pattern: #"value ([0-9]*) goes to bot ([0-9]*)"#) {
				.value(botIndex: Int(values[1])!, value: Int(values[0])!)
			} else if let values = line.getCapturedValues(pattern: #"bot ([0-9]*) gives low to ([a-z 0-9]*) and high to ([a-z 0-9]*)"#) {
				.give(botIndex: Int(values[0])!, low: parseOutput(from: values[1]), high: parseOutput(from: values[2]))
			} else {
				fatalError()
			}
		}

		return .init(instructions: instructions)
	}
}
