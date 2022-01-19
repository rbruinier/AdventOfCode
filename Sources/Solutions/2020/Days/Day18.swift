import Foundation
import Tools

final class Day18Solver: DaySolver {
    let dayNumber: Int = 18

    private var input: Input!

    private struct Input {
        let equations: [Equation]
    }

    private enum Operand {
        case value(_: Int)
        case equation(_: Equation)
    }

    private enum Operation {
        case add
        case product
    }

    private struct Equation {
        let operands: [Operand]
        let operations: [Operation]
    }

    private enum Precendence {
        case `default`
        case addition
    }

    private func solveEquation(equation: Equation, precedence: Precendence) -> Int {
        var result: Int

        var operandStack: [Operand] = equation.operands
        var operationStack: [Operation] = equation.operations

        switch operandStack.first! {
        case .value(let value): result = value
        case .equation(let equation): result = solveEquation(equation: equation, precedence: precedence)
        }

        operandStack.removeFirst()

        var multiplications: [Int] = [result]
        while let operation = operationStack.first {
            operationStack.removeFirst()

            let operand = operandStack.removeFirst()

            let operandValue: Int

            switch operand {
            case .value(let value): operandValue = value
            case .equation(let equation): operandValue = solveEquation(equation: equation, precedence: precedence)
            }

            switch precedence {
            case .default:
                switch operation {
                case .add: result += operandValue
                case .product: result *= operandValue
                }
            case .addition:
                switch operation {
                case .add: multiplications[multiplications.count - 1] += operandValue //result += operandValue
                case .product:
                    multiplications.append(operandValue)
                }
            }
        }

        switch precedence {
        case .default:
            return result
        case .addition:
            return multiplications.reduce(1, *)
        }
    }

    func solvePart1() -> Any {
        return input.equations.reduce(0, { $0 + solveEquation(equation: $1, precedence: .default)})
    }

    func solvePart2() -> Any {
        return input.equations.reduce(0, { $0 + solveEquation(equation: $1, precedence: .addition)})
    }

    func parseInput(rawString: String) {
        func parseEquation(from string: inout String) -> Equation {
            var operands: [Operand] = []
            var operations: [Operation] = []

            while let character = string.first {
                string.removeFirst()

                switch character {
                case " ": continue
                case "0" ... "9": operands.append(.value(Int(String(character))!))
                case "+": operations.append(.add)
                case "*": operations.append(.product)
                case "(": operands.append(.equation(parseEquation(from: &string)))
                case ")": return .init(operands: operands, operations: operations)
                default: fatalError()
                }
            }

            return Equation(operands: operands, operations: operations)
        }

        let equations: [Equation] = rawString.allLines().map {
            var string = $0

            return parseEquation(from: &string)
        }

        input = .init(equations: equations)
    }
}
