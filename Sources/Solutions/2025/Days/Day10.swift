import Collections
import Foundation
import Tools

/// Note: I've build part 1 using a BFS approach and it works fine. First I tried to modify part 1 approach for part 2 with joltages but it took too long to even solve the first entry
/// of the input. This is something that needs to be solved mathematically and it could have been done with Z3 (using Python) but instead I asked Claude Code for advice
/// and let it implement a native Swift ILP solver.
///
/// Update: part 2 is now solved without any solver following some tips given by a user on reddit:
/// https://www.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
/// Slower but neater.
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

	static func solveState(_ state: [Int], buttons: [[Int]], allButtonCombinations: [[Int]], memoization: inout [Int: Int?]) -> Int? {
		let hash = state.hashValue

		if let knownValue = memoization[hash] {
			return knownValue
		}

		var result: Int?

		buttomCombinationLoop: for buttonCombination in allButtonCombinations {
			var newState = state

			for buttonIndex in buttonCombination {
				for lightIndex in buttons[buttonIndex] {
					// early exit to next button combination in case we will get a negative joltage
					guard newState[lightIndex] != 0 else {
						continue buttomCombinationLoop
					}

					newState[lightIndex] -= 1
				}
			}

			// if we still have uneven numbers we ignore this and move on to another button combination
			if newState.contains(where: { $0 % 2 == 1 }) {
				continue
			}

			// if we have reached our goal we look at the result and continue to the next button combination
			if newState.reduce(0, +) == 0 {
				result = min(result, buttonCombination.count)

				continue
			}

			// now divide all by two
			newState = newState.map { $0 >> 1 }

			guard let numberOfPresses = solveState(newState, buttons: buttons, allButtonCombinations: allButtonCombinations, memoization: &memoization) else {
				continue
			}

			result = min(result, (2 * numberOfPresses) + buttonCombination.count)
		}

		memoization[hash] = result

		return result
	}

	func solvePart2(withInput input: Input) async -> Int {
		await withTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
			for instruction in input.instructions {
				taskGroup.addTask {
					var memoization: [Int: Int?] = [:]

					let buttons = instruction.buttons

					let buttonIndices = (0 ..< buttons.count).map { $0 }

					var allButtonCombinations: [[Int]] = [[]]

					for length in 1 ... buttonIndices.count {
						allButtonCombinations += buttonIndices.combinationsWithoutRepetition(length: length)
					}

					guard let result = Self.solveState(instruction.joltage, buttons: buttons, allButtonCombinations: allButtonCombinations, memoization: &memoization) else {
						preconditionFailure()
					}

					return result
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
