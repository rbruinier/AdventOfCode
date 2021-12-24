import Foundation

public func parseInput() -> Input {
    return .init(steps: [
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
        .init(operandA: 26, operandB: -12, operandC: 9)
    ])
}
