import Foundation

/*
 Note, I first looked at the input script and copy pasted the code for each input in an spreadsheet column. There
 I noticed the ops are all the same for each input and there are only three costants for ops 5, 6 and 16 that are
 different for each input.

 And if you look closer to the actual instructions it becomes clear that only the z register is caried over. x & y are
 reset before being used and w is immediately set to the input. Therefore the only relevant state to keep
 track of is z.
*/

public struct Step {
    let operandA: Int
    let operandB: Int
    let operandC: Int
}

public struct Input {
    let steps: [Step]
}

/** This is a reverse engineered version of the per input set of instructions:

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
func processState(input: Int, step: Step, z: Int) -> Int {
    if ((z % 26) + step.operandB) == input {
        return z / step.operandA
    }

    return ((z / step.operandA) * 26) + input + step.operandC
}

public func solutionFor(input: Input) -> Int {
    // As we know the result is completely z and digit input driven we just care about z states and their max values
    //
    // Brute force through all possible z values for each step and digit

    var zCache: [Int: Int] = [0: 0]

    for (stepIndex, step) in input.steps.enumerated() {
        print("Processing step \(stepIndex)")

        var newZCache: [Int: Int] = [:]

        for (z, minValue) in zCache {
            for digit in 1 ... 9 {
                let newZ = processState(input: digit, step: step, z: z)

                if let existingMinValue = newZCache[newZ] {
                    newZCache[newZ] = min(existingMinValue, (minValue * 10) + digit)
                } else {
                    newZCache[newZ] = (minValue * 10) + digit
                }
            }
        }

        zCache = newZCache
    }

    return zCache[0]!
}
