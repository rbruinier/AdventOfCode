import Foundation
import Tools

final class Day02Solver: DaySolver {
    let dayNumber: Int = 2

    private var input: Input!

    private struct Input {
        let program: [Int]
    }

//    private enum Instruction {
//        case add(operandIndex1: Int, operandIndex2: Int, targetIndex: Int)
//        case mul(operandIndex1: Int, operandIndex2: Int, targetIndex: Int)
//        case halt
//    }
//
//    private func executeProgram(_ originalOrogram: [Int]) -> Int {
//        var program = originalOrogram
//
//        var ip = 0
//
//        instructionLoop: while ip < program.count {
//            let instruction: Instruction
//
//            switch program[ip] {
//            case 1:
//                instruction = .add(operandIndex1: program[ip + 1], operandIndex2: program[ip + 2], targetIndex: program[ip + 3])
//            case 2:
//                instruction = .mul(operandIndex1: program[ip + 1], operandIndex2: program[ip + 2], targetIndex: program[ip + 3])
//            case 99:
//                instruction = .halt
//            default: fatalError("Unknown instruction")
//            }
//
//            switch instruction {
//            case .add(let operandIndex1, let operandIndex2, let targetIndex):
//                program[targetIndex] = program[operandIndex1] + program[operandIndex2]
//            case .mul(let operandIndex1, let operandIndex2, let targetIndex):
//                program[targetIndex] = program[operandIndex1] * program[operandIndex2]
//            case .halt:
//                break instructionLoop
//            }
//
//            ip += 4
//        }
//
//        return program[0]
//    }

    func solvePart1() -> Any {
        var program = input.program

        program[1] = 12
        program[2] = 2

        let intcode = IntcodeProcessor()

        return intcode.executeProgram(program, input: []).memory[0]
    }

    func solvePart2() -> Any {
        let intcode = IntcodeProcessor()

        var program = input.program

        for noun in 0 ... 99 {
            for verb in 0 ... 99 {
                program[1] = noun
                program[2] = verb

                if intcode.executeProgram(program, input: []).memory[0] == 19690720 {
                    return 100 * noun + verb
                }
            }
        }

        return -1
    }

    func parseInput(rawString: String) {
        input = .init(program: rawString.parseCommaSeparatedInts())
    }
}
