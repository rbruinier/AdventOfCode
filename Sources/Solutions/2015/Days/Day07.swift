import Foundation
import Tools

final class Day07Solver: DaySolver {
    let dayNumber: Int = 7

    private var input: Input!

    private struct Input {
        let instructions: [Instruction]
    }
    
    private enum Operand {
        case constant(value: Int)
        case register(id: String)
    }
    
    private enum Instruction {
        case mov(value: Operand, targetRegisterId: String)
        case and(lhs: Operand, rhs: Operand, targetRegisterId: String)
        case or(lhs: Operand, rhs: Operand, targetRegisterId: String)
        case shl(lhs: Operand, rhs: Operand, targetRegisterId: String)
        case shr(lhs: Operand, rhs: Operand, targetRegisterId: String)
        case not(registerId: String, targetRegisterId: String)
        
        var targetRegisterId: String {
            switch self {
            case .mov(_, let registerId): return registerId
            case .and(_, _, let registerId): return registerId
            case .or(_, _, let registerId): return registerId
            case .shl(_, _, let registerId): return registerId
            case .shr(_, _, let registerId): return registerId
            case .not(_, let registerId): return registerId
            }
        }
    }
    
    private func valueFor(operand: Operand, registers: [String: Int]) -> Int? {
        switch operand {
        case .constant(let value):
            return value
        case .register(let registerId):
            return registers[registerId]
        }
    }
    
    private func execute(instructions originalInstructions: [Instruction], registers originalRegisters: [String: Int]) -> [String: Int] {
        var registers = originalRegisters
        var instructions = originalInstructions
        
        while true {
            var remainingInstructions: [Instruction] = []

            for instruction in instructions {
                let targetRegisterId = instruction.targetRegisterId
                
                switch instruction {
                case .mov(let operand, _):
                    guard let value = valueFor(operand: operand, registers: registers) else {
                        remainingInstructions.append(instruction)
                        
                        continue
                    }
                    
                    registers[targetRegisterId] = value
                case .and(let lhs, let rhs, _):
                    guard
                        let lhs = valueFor(operand: lhs, registers: registers),
                        let rhs = valueFor(operand: rhs, registers: registers)
                    else {
                        remainingInstructions.append(instruction)

                        continue
                    }
                    
                    registers[targetRegisterId] = lhs & rhs
                case .or(let lhs, let rhs, _):
                    guard
                        let lhs = valueFor(operand: lhs, registers: registers),
                        let rhs = valueFor(operand: rhs, registers: registers)
                    else {
                        remainingInstructions.append(instruction)

                        continue
                    }
                    
                    registers[targetRegisterId] = lhs | rhs
                case .shl(let lhs, let rhs, _):
                    guard
                        let lhs = valueFor(operand: lhs, registers: registers),
                        let rhs = valueFor(operand: rhs, registers: registers)
                    else {
                        remainingInstructions.append(instruction)

                        continue
                    }
                    
                    registers[targetRegisterId] = lhs << rhs
                case .shr(let lhs, let rhs, _):
                    guard
                        let lhs = valueFor(operand: lhs, registers: registers),
                        let rhs = valueFor(operand: rhs, registers: registers)
                    else {
                        remainingInstructions.append(instruction)

                        continue
                    }
                    
                    registers[targetRegisterId] = lhs >> rhs
                case .not(let registerId, _):
                    guard let value = registers[registerId] else {
                        remainingInstructions.append(instruction)

                        continue
                    }
                    
                    registers[targetRegisterId] = value ^ 0xFFFF
                }
            }
            
            if remainingInstructions.isEmpty {
                break
            }
            
            instructions = remainingInstructions
        }
        
        return registers
    }

    func solvePart1() -> Any {
        let registers = execute(instructions: input.instructions, registers: [:])
        
        return registers["a"]!
    }

    func solvePart2() -> Any {
        var registers = execute(instructions: input.instructions, registers: [:])

        let newInstructions: [Instruction] = input.instructions.map { instruction in
            if case .mov(_, let targetRegisterId) = instruction, targetRegisterId == "b" {
                return .mov(value: .constant(value: registers["a"]!), targetRegisterId: "b")
            } else {
                return instruction
            }
        }

        registers = execute(instructions: newInstructions, registers: [:])

        return registers["a"]!
    }

    func parseInput(rawString: String) {
        let instructions: [Instruction] = rawString.allLines().map { line in
            func operand(from string: String) -> Operand {
                if let value = Int(string) {
                    return .constant(value: value)
                } else {
                    return .register(id: string)
                }
            }
            
            if let arguments = line.getCapturedValues(pattern:  #"([a-zA-Z0-9]*) AND ([a-zA-Z0-9]*) -> ([a-zA-Z0-9]*)"#) {
                return .and(lhs: operand(from: arguments[0]), rhs: operand(from: arguments[1]), targetRegisterId: arguments[2])
            } else if let arguments = line.getCapturedValues(pattern:  #"([a-zA-Z0-9]*) OR ([a-zA-Z0-9]*) -> ([a-zA-Z0-9]*)"#) {
                return .or(lhs: operand(from: arguments[0]), rhs: operand(from: arguments[1]), targetRegisterId: arguments[2])
            } else if let arguments = line.getCapturedValues(pattern:  #"([a-zA-Z0-9]*) LSHIFT ([a-zA-Z0-9]*) -> ([a-zA-Z0-9]*)"#) {
                return .shl(lhs: operand(from: arguments[0]), rhs: operand(from: arguments[1]), targetRegisterId: arguments[2])
            } else if let arguments = line.getCapturedValues(pattern:  #"([a-zA-Z0-9]*) RSHIFT ([a-zA-Z0-9]*) -> ([a-zA-Z0-9]*)"#) {
                return .shr(lhs: operand(from: arguments[0]), rhs: operand(from: arguments[1]), targetRegisterId: arguments[2])
            } else if let arguments = line.getCapturedValues(pattern:  #"NOT ([a-zA-Z0-9]*) -> ([a-zA-Z0-9]*)"#) {
                return .not(registerId: arguments[0], targetRegisterId: arguments[1])
            } else if let arguments = line.getCapturedValues(pattern:  #"([a-zA-Z0-9]*) -> ([a-zA-Z0-9]*)"#) {
                return .mov(value: operand(from: arguments[0]), targetRegisterId: arguments[1])
            }
            
            fatalError()
        }
        
        input = .init(instructions: instructions)
    }
}
