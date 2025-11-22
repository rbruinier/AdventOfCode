import Foundation
import Tools

final class Day23Solver: DaySolver {
	let dayNumber: Int = 23

	struct Input {
		let program: [Int]
	}

	private final class Computer {
		let address: Int
		var intcode: IntcodeProcessor
		var inputBuffer: [Int] = []
		var ouputBuffer: [Int] = []

		var inputBufferFinished: Bool = false

		init(address: Int, intcode: IntcodeProcessor) {
			self.address = address
			self.intcode = intcode

			inputBuffer.append(address)
			inputBuffer.append(-1)
		}

		func pushInputValue(_ value: Int) {
			inputBuffer.append(value)

			inputBufferFinished = false
		}

		func nextInputValue() -> Int? {
			if let value = inputBuffer.first {
				inputBuffer.removeFirst()

				return value
			} else {
				inputBufferFinished = true

				return -1
			}
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		var computers: [Computer] = []

		for address in 0 ..< 50 {
			computers.append(Computer(address: address, intcode: IntcodeProcessor(program: input.program)))
		}

		while true {
			for i in 0 ..< 50 {
				let computer = computers[i]

				// make sure the buffer sends once the input finished signal
				computer.pushInputValue(-1)

				var outputBuffer: [Int] = []

				while true {
					if let output = computer.intcode.continueProgramTillOutputOrInput(input: &computer.inputBuffer) {
						outputBuffer.append(output)

						if outputBuffer.count == 3 {
							let id = outputBuffer[0]
							let x = outputBuffer[1]
							let y = outputBuffer[2]

							if id == 255 {
								return y
							}

							computers[id].pushInputValue(x)
							computers[id].pushInputValue(y)

							outputBuffer.removeAll()
						}
					} else {
						break
					}
				}
			}
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		var computers: [Computer] = []

		for address in 0 ..< 50 {
			computers.append(Computer(address: address, intcode: IntcodeProcessor(program: input.program)))
		}

		var natX = 0
		var natY = 0

		var lastSentY = 0

		while true {
			var isIdle = true

			for i in 0 ..< 50 {
				let computer = computers[i]

				// make sure the buffer sends once the input finished signal
				computer.pushInputValue(-1)

				var outputBuffer: [Int] = []

				while true {
					if let output = computer.intcode.continueProgramTillOutputOrInput(input: &computer.inputBuffer) {
						outputBuffer.append(output)

						if outputBuffer.count == 3 {
							let id = outputBuffer[0]
							let x = outputBuffer[1]
							let y = outputBuffer[2]

							if id == 255 {
								natX = x
								natY = y

								continue
							} else {
								isIdle = false
							}

							computers[id].pushInputValue(x)
							computers[id].pushInputValue(y)

							outputBuffer.removeAll()
						}
					} else {
						break
					}
				}
			}

			if isIdle {
				if lastSentY == natY {
					return natY
				}

				lastSentY = natY

				computers[0].pushInputValue(natX)
				computers[0].pushInputValue(natY)
			}
		}
	}

	func parseInput(rawString: String) -> Input {
		.init(program: rawString.parseCommaSeparatedInts())
	}
}
