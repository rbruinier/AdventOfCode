import Foundation
import Tools

final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	private var input: Input!

	/*
	  I first looked at the input script and copy pasted the code for each input in an spreadsheet column. There
	  I noticed the ops are all the same for each input and there are only three constants for ops 5, 6 and 16 that are
	  different for each input.

	  And if you look closer to the actual instructions it becomes clear that only the z register is carried over. x & y are
	  reset before being used and w is immediately set to the input. Therefore the only relevant state to keep
	  track of is z.
	 */

	private struct Step {
		let operandA: Int
		let operandB: Int
		let operandC: Int
	}

	private struct Input {
		let steps: [Step]
	}

	// as part 2 can be calculated during part 1 we cache the result
	private var cachedResults: (min: Int, max: Int)!

	/**
	 This is a reverse engineered version of the per input set of instructions:

	     state.w = input                      // inp w
	     state.x = state.z % 26               // mul x 0 -> add x z -> mod x 26
	     state.z = state.z / step.operandA    // div z [operandA]
	     state.x = state.x + step.operandB    // add x [operandB]
	     state.x = state.x == state.w ? 1 : 0 // eql x w
	     state.x = state.x == state.w ? 0 : 1 // eql x 0
	     state.y = (25 * state.x) + 1         // mul y 0 -> add y 25 -> mul y x -> add y 1
	     state.z = state.z * state.y          // mul z y
	     state.y = input + step.operandC      // mul y 0 -> add y w -> add y [operandC]
	     state.y = state.y * state.x          // mul y x
	     state.z = state.z + state.y          // add z y
	 */
	private func processState(input: Int, step: Step, z: Int) -> Int {
		if ((z % 26) + step.operandB) == input {
			return z / step.operandA
		}

		return ((z / step.operandA) * 26) + input + step.operandC
	}

	func solvePart1() -> Int {
		// As we know the result is completely z and digit input driven we just care about z states and their max values
		//
		// Brute force through all possible z values for each step and digit

		var zCache: [Int: (min: Int, max: Int)] = [0: (0, 0)]

		for (_, step) in input.steps.enumerated() {
			var newZCache: [Int: (min: Int, max: Int)] = [:]

			for (z, values) in zCache {
				for digit in 1 ... 9 {
					let newZ = processState(input: digit, step: step, z: z)

					if let existingValues = newZCache[newZ] {
						let max = max(existingValues.max, (values.max * 10) + digit)
						let min = min(existingValues.min, (values.min * 10) + digit)

						newZCache[newZ] = (min: min, max: max)
					} else {
						let max = (values.max * 10) + digit
						let min = (values.min * 10) + digit

						newZCache[newZ] = (min: min, max: max)
					}
				}
			}

			zCache = newZCache
		}

		cachedResults = (min: zCache[0]!.min, max: zCache[0]!.max)

		return cachedResults.max
	}

	func solvePart2() -> Int {
		cachedResults.min
	}

	func parseInput(rawString: String) {
		input = .init(steps: [
			.init(operandA: 1, operandB: 10, operandC: 12),
			.init(operandA: 1, operandB: 10, operandC: 10),
			.init(operandA: 1, operandB: 12, operandC: 8),
			.init(operandA: 1, operandB: 11, operandC: 4),
			.init(operandA: 26, operandB: 0, operandC: 3),
			.init(operandA: 1, operandB: 15, operandC: 10),
			.init(operandA: 1, operandB: 13, operandC: 6),
			.init(operandA: 26, operandB: -12, operandC: 13),
			.init(operandA: 26, operandB: -15, operandC: 8),
			.init(operandA: 26, operandB: -15, operandC: 1),
			.init(operandA: 26, operandB: -4, operandC: 7),
			.init(operandA: 1, operandB: 10, operandC: 6),
			.init(operandA: 26, operandB: -5, operandC: 9),
			.init(operandA: 26, operandB: -12, operandC: 9),
		])
	}
}
