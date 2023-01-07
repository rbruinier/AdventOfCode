import Foundation
import Tools

final class Day05Solver: DaySolver {
    let dayNumber: Int = 5

    let expectedPart1Result = 9654885
    let expectedPart2Result = 7079459

    private var input: Input!

    private struct Input {
        let program: [Int]
    }

    func solvePart1() -> Int {
        let intcode = IntcodeProcessor()

        let output = intcode.executeProgram(input.program, input: [1]).output

        return output.last!
    }

    func solvePart2() -> Int {
        let intcode = IntcodeProcessor()

        let output = intcode.executeProgram(input.program, input: [5]).output

        return output.last!
    }

    func parseInput(rawString: String) {
        input = .init(program: rawString.parseCommaSeparatedInts())
    }
}
