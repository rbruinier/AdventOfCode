import Foundation
import Tools

final class Day09Solver: DaySolver {
    let dayNumber: Int = 9

    private var input: Input!

    private struct Input {
        let program: [Int]
    }

    func solvePart1() -> Any {
        let intcode = IntcodeProcessor()

        return intcode.executeProgram(input.program, input: [1]).output.first!
    }

    func solvePart2() -> Any {
        let intcode = IntcodeProcessor()

        return intcode.executeProgram(input.program, input: [2]).output.first!
    }

    func parseInput(rawString: String) {
        input = .init(program: rawString.parseCommaSeparatedInts())
    }
}
