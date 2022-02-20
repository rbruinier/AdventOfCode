import Foundation
import Tools

final class Day23Solver: DaySolver {
    let dayNumber: Int = 23

    private var input: Input!

    private struct Input {
        let instructions: [Instruction]
    }

    private enum Value {
        case constant(value: Int)
        case register(id: String)
    }

    private enum Instruction {
        case half(registerId: String)
        case triple(registerId: String)
        case inc(registerId: String)
        case jump(offset: Int)
        case jumpOnEven(registerId: String, offset: Int)
        case jumpOnOne(registerId: String, offset: Int)
    }

    private struct CPU {
        let program: [Instruction]

        var a: Int = 0
        var b: Int = 0

        var ip: Int = 0

        var isCompleted: Bool {
            return ip == program.count
        }

        mutating func executeNextInstruction() -> Bool {
            guard ip >= 0 && ip < program.count else {
                return false
            }

            let instruction = program[ip]

            switch instruction {
            case .half(let registerId):
                switch registerId {
                case "a": a /= 2
                case "b": b /= 2
                default: fatalError()
                }
            case .triple(let registerId):
                switch registerId {
                case "a": a *= 3
                case "b": b *= 3
                default: fatalError()
                }
            case .inc(let registerId):
                switch registerId {
                case "a": a += 1
                case "b": b += 1
                default: fatalError()
                }
            case .jump(let offset):
                ip += offset - 1
            case .jumpOnEven(let registerId, let offset):
                let isEven: Bool

                switch registerId {
                case "a": isEven = (a % 2) == 0
                case "b": isEven = (b % 2) == 0
                default: fatalError()
                }

                if isEven {
                    ip += offset - 1
                }
            case .jumpOnOne(let registerId, let offset):
                let doJump: Bool

                switch registerId {
                case "a": doJump = a == 1
                case "b": doJump = b == 1
                default: fatalError()
                }

                if doJump {
                    ip += offset - 1
                }
            }

            ip += 1

            return true
        }
    }
    func solvePart1() -> Any {
        var cpu = CPU(program: input.instructions)

        while cpu.executeNextInstruction() {
        }

        return cpu.b
    }

    func solvePart2() -> Any {
        var cpu = CPU(program: input.instructions)

        cpu.a = 1

        while cpu.executeNextInstruction() {
        }

        return cpu.b
    }

    func parseInput(rawString: String) {
        let instructions: [Instruction] = rawString.allLines().map { line in
            if let parameters = line.getCapturedValues(pattern: #"hlf ([a-b])"#) {
                return .half(registerId: parameters[0])
            } else if let parameters = line.getCapturedValues(pattern: #"tpl ([a-b])"#) {
                return .triple(registerId: parameters[0])
            } else if let parameters = line.getCapturedValues(pattern: #"inc ([a-b])"#) {
                return .inc(registerId: parameters[0])
            } else if let parameters = line.getCapturedValues(pattern: #"jmp ([-+][0-9]*)"#) {
                return .jump(offset: Int(parameters[0])!)
            } else if let parameters = line.getCapturedValues(pattern: #"jie ([a-b]), ([-+][0-9]*)"#) {
                return .jumpOnEven(registerId: parameters[0], offset: Int(parameters[1])!)
            } else if let parameters = line.getCapturedValues(pattern: #"jio ([a-b]), ([-+][0-9]*)"#) {
                return .jumpOnOne(registerId: parameters[0], offset: Int(parameters[1])!)
            } else {
                fatalError()
            }
        }

        input = .init(instructions: instructions)
    }
}
