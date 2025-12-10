import Collections
import Foundation
import Tools

/// Note: I've build part 1 using a BFS approach and it works fine. First I tried to modify part 1 approach for part 2 with joltages but it took too long to even solve the first entry
/// of the input. This is something that needs to be solved mathematically and it could have been done with Z3 (using Python) but instead I asked Claude Code for advice
/// and let it implement a native Swift ILP solver.
final class Day10Solver: DaySolver {
	let dayNumber: Int = 10

	private var input: Input!

	struct Instructions {
		let lights: [Bool]
		let buttons: [[Int]]
		let joltage: [Int]

		let numberOfLights: Int
	}

	struct Input {
		let instructions: [Instructions]
	}

	func solvePart1(withInput input: Input) async -> Int {
		await withTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
			for instructions in input.instructions {
				taskGroup.addTask {
					let desiredState = instructions.lights

					struct State {
						let lights: [Bool]
						var numberOfButtonPresses: Int
					}

					// BFS
					var queue: Deque<State> = [State(lights: [Bool](repeating: false, count: instructions.numberOfLights), numberOfButtonPresses: 0)]

					var lowestNumberOfButtonPresses = Int.max

					var hashCache: [Int: Int] = [:]

					while let state = queue.popFirst() {
						for button in instructions.buttons {
							var lights: [Bool] = state.lights

							for lightIndex in button {
								lights[lightIndex].toggle()
							}

							let hash = lights.hashValue

							let newState = State(lights: lights, numberOfButtonPresses: state.numberOfButtonPresses + 1)

							if let existingValue = hashCache[hash], newState.numberOfButtonPresses >= existingValue {
								continue
							}

							hashCache[hash] = newState.numberOfButtonPresses

							if lights == desiredState {
								if newState.numberOfButtonPresses < lowestNumberOfButtonPresses {
									lowestNumberOfButtonPresses = newState.numberOfButtonPresses
								}
							} else {
								if newState.lights.count >= lowestNumberOfButtonPresses {
									continue
								}

								queue.append(newState)
							}
						}
					}

					return lowestNumberOfButtonPresses
				}
			}

			return await taskGroup.reduce(into: 0) { $0 += $1 }
		}
	}

	func solvePart2(withInput input: Input) async -> Int {
		await withTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
			for instructions in input.instructions {
				taskGroup.addTask {
					// Build the matrix (each row is a counter, each column is a button)
					// matrix[counter][button] = 1 if button increments that counter, else 0
					// Note: The ILP solver is written by Claude Code
					var matrix: [[Int]] = Array(
						repeating: Array(repeating: 0, count: instructions.buttons.count),
						count: instructions.joltage.count
					)

					for (buttonIndex, button) in instructions.buttons.enumerated() {
						for counterIndex in button {
							matrix[counterIndex][buttonIndex] = 1
						}
					}

					// Solve using ILP solver
					guard let solution = ILPSolver.solve(matrix: matrix, targets: instructions.joltage) else {
						preconditionFailure()
					}

					return solution.reduce(0, +)
				}
			}

			return await taskGroup.reduce(into: 0) { $0 += $1 }
		}
	}

	func parseInput(rawString: String) -> Input {
		let instructions: [Instructions] = rawString.allLines().map { line in
			let closingBracketIndex = line.firstIndex(of: "]")!.utf16Offset(in: line)
			let openCurlyBraceIndex = line.firstIndex(of: "{")!.utf16Offset(in: line)

			let lightsAsString = line[1 ..< closingBracketIndex]
			let buttonsAsString = line[closingBracketIndex + 2 ..< openCurlyBraceIndex - 1]
			let joltagesAsString = line[openCurlyBraceIndex + 1 ..< line.count - 1]

			let lights: [Bool] = lightsAsString.map { String($0) == "#" }
			let buttons: [[Int]] = buttonsAsString.components(separatedBy: " ").map { section in
				section[1 ..< section.count - 1].parseCommaSeparatedInts()
			}
			let joltages: [Int] = joltagesAsString.parseCommaSeparatedInts()

			assert(lights.count == joltages.count)

			return Instructions(lights: lights, buttons: buttons, joltage: joltages, numberOfLights: lights.count)
		}

		return .init(instructions: instructions)
	}
}
