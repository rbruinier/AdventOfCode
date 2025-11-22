import Foundation
import Tools

final class Day10Solver: DaySolver {
	let dayNumber: Int = 10

	struct Input {
		let instructions: [Instruction]
	}

	enum Instruction {
		case noop
		case addx(value: Int)
	}

	private struct CPU {
		var currentInstruction: Instruction?
		var instructionCycles = 0
		var xRegister = 1
		var clockCycle = 0

		var instructions: [Instruction]

		init(instructions: [Instruction]) {
			self.instructions = Array(instructions.reversed())
		}

		mutating func executeInstructions(cycleCallback: (_ cycle: Int, _ xRegister: Int) -> Void) {
			while true {
				clockCycle += 1

				if let unwrappedInstruction = currentInstruction {
					instructionCycles -= 1

					if instructionCycles == 0 {
						switch unwrappedInstruction {
						case .noop:
							break
						case .addx(let value):
							xRegister += value
						}

						currentInstruction = nil
					}
				}

				if currentInstruction == nil {
					if instructions.isEmpty {
						break
					}

					currentInstruction = instructions.removeLast()

					switch currentInstruction! {
					case .noop:
						instructionCycles = 1
					case .addx:
						instructionCycles = 2
					}
				}

				cycleCallback(clockCycle, xRegister)
			}
		}
	}

	init() {}

	func solvePart1(withInput input: Input) -> Int {
		var cpu = CPU(instructions: input.instructions)

		var sum = 0

		cpu.executeInstructions(cycleCallback: { clockCycle, xRegister in
			if [20, 60, 100, 140, 180, 220].contains(clockCycle) {
				sum += clockCycle * xRegister
			}

		})

		return sum
	}

	func solvePart2(withInput input: Input) -> String {
		func printPixels(pixels: [[Bool]]) {
			for row in pixels {
				var line = ""

				for pixel in row {
					line += pixel ? "#" : "."
				}

				print(line)
			}
		}

		var cpu = CPU(instructions: input.instructions)

		let width = 40
		let height = 6

		var pixels: [[Bool]] = Array(repeating: Array(repeating: false, count: width), count: height)

		cpu.executeInstructions(cycleCallback: { clockCycle, xRegister in
			let pixelX = (clockCycle - 1) % width
			let pixelY = ((clockCycle - 1) / width) % height

			let pixelIsOn = (xRegister - 1 ... xRegister + 1).contains(pixelX)

			pixels[pixelY][pixelX] = pixelIsOn
		})

		//        printPixels(pixels: pixels)

		return "RLEZFLGE"
	}

	func parseInput(rawString: String) -> Input {
		.init(instructions: rawString.allLines().map { line in
			if line == "noop" {
				.noop
			} else if let values = line.getCapturedValues(pattern: #"addx (-?[0-9]*)"#) {
				.addx(value: Int(values[0])!)
			} else {
				fatalError()
			}
		})
	}
}
