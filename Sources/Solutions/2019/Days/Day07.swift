import Foundation
import Tools

final class Day07Solver: DaySolver {
    let dayNumber: Int = 7

    private var input: Input!

    private struct Input {
        let program: [Int]
    }

    func solvePart1() -> Any {
        let intcode = IntcodeProcessor()

        let permutations = [0, 1, 2, 3, 4].permutations

        var maxThrusterSignal = 0

        for permutation in permutations {
            var currentInput = 0

            for phaseSetting in permutation {
                currentInput = intcode.executeProgram(input.program, input: [phaseSetting, currentInput]).output.last!
            }

            maxThrusterSignal = max(maxThrusterSignal, currentInput)
        }

        return maxThrusterSignal
    }

    func solvePart2() -> Any {
        let permutations = [5, 6, 7, 8, 9].permutations

        var maxThrusterSignal = 0

        for permutation in permutations {
            let amplifiers: [IntcodeProcessor] = [
                IntcodeProcessor(),
                IntcodeProcessor(),
                IntcodeProcessor(),
                IntcodeProcessor(),
                IntcodeProcessor()
            ]

            var currentInput = 0
            var iteration = 0

            iterationLoop: while true {
                for (amplifierIndex, phaseSetting) in permutation.enumerated() {
                    if iteration == 0 {
                        guard let newCurrentInput = amplifiers[amplifierIndex].executeProgramTillOutput(input.program, input: [phaseSetting, currentInput]) else {
                            fatalError()
                        }

                        currentInput = newCurrentInput
                    } else {
                        if let newCurrentInput = amplifiers[amplifierIndex].continueProgramTillOutput(input: [currentInput]) {
                            currentInput = newCurrentInput
                        } else {
                            break iterationLoop
                        }

                    }

                    maxThrusterSignal = max(maxThrusterSignal, currentInput)
                }

                iteration += 1
            }
        }

        return maxThrusterSignal
    }

    func parseInput(rawString: String) {
        input = .init(program: rawString.parseCommaSeparatedInts())
    }
}
