import Foundation

final class IntcodeProcessor {
    private enum Value: CustomStringConvertible {
        case position(index: Int)
        case immediate(value: Int)
        case relative(offset: Int)

        init(_ value: Int, flags: Int, index: Int) {
            let type = flags / Int(pow(10.0, Double(index))) % 10

            switch type {
            case 0: self = .position(index: value)
            case 1: self = .immediate(value: value)
            case 2: self = .relative(offset: value)
            default: fatalError("Unexpected position type")
            }
        }

        var description: String {
            switch self {
            case .position(let index): return "pos(\(index))"
            case .immediate(let value): return "immediate(\(value))"
            case .relative(let offset): return "relative(\(offset))"
            }
        }
    }

    private enum Instruction: CustomStringConvertible {
        case add(operand1: Value, operand2: Value, targetIndex: Value)
        case mul(operand1: Value, operand2: Value, targetIndex: Value)
        case input(targetIndex: Value)
        case output(operandIndex: Value)
        case jumpIfTrue(operand1: Value, operand2: Value)
        case jumpIfFalse(operand1: Value, operand2: Value)
        case lessThan(operand1: Value, operand2: Value, targetIndex: Value)
        case equals(operand1: Value, operand2: Value, targetIndex: Value)
        case relativeBase(operand: Value)
        case halt

//        if state.value(at: operand1) != 0 {
//            state.ip = state.value(at: operand2)
//        }

        var description: String {
            switch self {
            case .add(let operand1, let operand2, let targetOperand):
                return "ADD \(operand1) + \(operand2) -> \(targetOperand)"
            case .mul(let operand1, let operand2, let targetOperand):
                return "MUL \(operand1) * \(operand2) -> \(targetOperand)"
            case .input(let targetOperand):
                return "INPUT -> \(targetOperand)"
            case .output(let operand):
                return "OUTPUT \(operand)"
            case .jumpIfTrue(let operand1, let operand2):
                return "JMPIFTRUE \(operand1) != 0 -> IP = \(operand2)"
            case .jumpIfFalse(let operand1, let operand2):
                return "JMPIFFALSE \(operand1) == 0 -> IP = \(operand2)"
            case .lessThan(let operand1, let operand2, let targetOperand):
                return "LESSTHAN \(operand1) < \(operand2) -> \(targetOperand)"
            case .equals(let operand1, let operand2, let targetOperand):
                return "EQUALS \(operand1) == \(operand2) -> \(targetOperand)"
            case .relativeBase(let operand):
                return "RELBASE \(operand) -> relativeBase"
            case .halt:
                return "HALT"
            }
        }
    }

    private struct State {
        var memory: [Int]
        var ip: Int = 0
        var relativeBase: Int = 0

        func operand(at index: Int) -> Int {
            return memory[ip + index]
        }

        mutating func setValue(_ value: Int, at index: Int) {
            // auto grow memory when required
            if index >= memory.count {
                memory += Array(repeating: 0, count: (index - memory.count) + 1)
            }

            memory[index] = value
        }

        mutating func setValue(_ value: Int, at operand: Value) {
            let index: Int

            switch operand {
            case .immediate(_): fatalError("Cannot output to immediate")
            case .position(let absoluteIndex): index = absoluteIndex
            case .relative(let offset): index = relativeBase + offset
            }

            // auto grow memory when required
            if index >= memory.count {
                memory += Array(repeating: 0, count: (index - memory.count) + 1)
            }

            memory[index] = value
        }

        mutating func value(at operand: Value) -> Int {
            let index: Int

            switch operand {
            case .immediate(let value): return value
            case .position(let absoluteIndex): index = absoluteIndex
            case .relative(let offset): index = relativeBase + offset
            }

            // auto grow memory when required
            if index >= memory.count {
                memory += Array(repeating: 0, count: (index - memory.count) + 1)
            }

            return memory[index]
        }

        var isValidIp: Bool {
            ip < memory.count
        }
    }

    private var state: State!

    init() {
    }

    init(program: [Int]) {
        state = State(memory: program)
    }

    func executeProgram(_ originalProgram: [Int], input originalInput: [Int]) -> (output: [Int], memory: [Int]) {
        state = State(memory: originalProgram)

        var input = originalInput
        var output: [Int] = []

        while let instruction = parseNextInstruction() {
            let shouldContinue = executeInstruction(instruction, input: &input, output: &output)

            guard shouldContinue else {
                break
            }
        }

        return (output: output, memory: state.memory)
    }

//    var currentMemoryContent: [Int] {
//        return state.memory
//    }

    func executeProgramTillOutput(_ originalProgram: [Int], input originalInput: [Int]) -> Int? {
        state = State(memory: originalProgram)

        return continueProgramTillOutput(input: originalInput)
    }

    func continueProgramTillOutput(input originalInput: [Int]) -> Int? {
        var input = originalInput
        var output: [Int] = []

        while let instruction = parseNextInstruction() {
            let shouldContinue = executeInstruction(instruction, input: &input, output: &output)

            if let outputValue = output.first {
                return outputValue
            }

            guard shouldContinue else {
                return nil
            }
        }

        return nil
    }

    func continueProgramTillOutput(input: inout [Int]) -> Int? {
        var output: [Int] = []

        while let instruction = parseNextInstruction() {
            let shouldContinue = executeInstruction(instruction, input: &input, output: &output)

            if let outputValue = output.first {
                return outputValue
            }

            guard shouldContinue else {
                return nil
            }
        }

        return nil
    }

    private func parseNextInstruction() -> Instruction? {
        guard state.isValidIp else {
            return nil
        }

        let instruction: Instruction

        let opcode = state.operand(at: 0) % 100
        let flags = state.operand(at: 0) / 100

        switch opcode {
        case 1:
            instruction = .add(operand1: Value(state.operand(at: 1), flags: flags, index: 0), operand2: Value(state.operand(at: 2), flags: flags, index: 1), targetIndex: Value(state.operand(at: 3), flags: flags, index: 2))

            state.ip += 4
        case 2:
            instruction = .mul(operand1: Value(state.operand(at: 1), flags: flags, index: 0), operand2: Value(state.operand(at: 2), flags: flags, index: 1), targetIndex: Value(state.operand(at: 3), flags: flags, index: 2))

            state.ip += 4
        case 3:
            instruction = .input(targetIndex: Value(state.operand(at: 1), flags: flags, index: 0))

            state.ip += 2
        case 4:
            instruction = .output(operandIndex: Value(state.operand(at: 1), flags: flags, index: 0))

            state.ip += 2
        case 5:
            instruction = .jumpIfTrue(operand1: Value(state.operand(at: 1), flags: flags, index: 0), operand2: Value(state.operand(at: 2), flags: flags, index: 1))

            state.ip += 3
        case 6:
            instruction = .jumpIfFalse(operand1: Value(state.operand(at: 1), flags: flags, index: 0), operand2: Value(state.operand(at: 2), flags: flags, index: 1))

            state.ip += 3
        case 7:
            instruction = .lessThan(operand1: Value(state.operand(at: 1), flags: flags, index: 0), operand2: Value(state.operand(at: 2), flags: flags, index: 1), targetIndex: Value(state.operand(at: 3), flags: flags, index: 2))

            state.ip += 4
        case 8:
            instruction = .equals(operand1: Value(state.operand(at: 1), flags: flags, index: 0), operand2: Value(state.operand(at: 2), flags: flags, index: 1), targetIndex: Value(state.operand(at: 3), flags: flags, index: 2))

            state.ip += 4
        case 9:
            instruction = .relativeBase(operand: Value(state.operand(at: 1), flags: flags, index: 0))

            state.ip += 2
        case 99:
            instruction = .halt

            state.ip += 1
        default: fatalError("Unknown instruction")
        }

        return instruction
    }

    private func executeInstruction(_ instruction: Instruction, input: inout [Int], output: inout [Int]) -> Bool {
//        print(instruction)

        switch instruction {
        case .add(let operand1, let operand2, let targetIndex):
            let value1 = state.value(at: operand1)
            let value2 = state.value(at: operand2)

            state.setValue(value1 + value2, at: targetIndex)
        case .mul(let operand1, let operand2, let targetIndex):
            let value1 = state.value(at: operand1)
            let value2 = state.value(at: operand2)

            state.setValue(value1 * value2, at: targetIndex)
        case .input(let targetIndex):
            state.setValue(input.removeFirst(), at: targetIndex)
        case .output(let operand):
            output.append(state.value(at: operand))
        case .jumpIfTrue(let operand1, let operand2):
            if state.value(at: operand1) != 0 {
                state.ip = state.value(at: operand2)
            }
        case .jumpIfFalse(let operand1, let operand2):
            if state.value(at: operand1) == 0 {
                state.ip = state.value(at: operand2)
            }
        case .lessThan(let operand1, let operand2, let targetIndex):
            let value = state.value(at: operand1) < state.value(at: operand2) ? 1 : 0

            state.setValue(value, at: targetIndex)
        case .equals(let operand1, let operand2, let targetIndex):
            let value = state.value(at: operand1) == state.value(at: operand2) ? 1 : 0

            state.setValue(value, at: targetIndex)
        case .relativeBase(let operand):
            let value = state.value(at: operand)

            state.relativeBase += value
        case .halt:
            return false
        }

        return true
    }
}
